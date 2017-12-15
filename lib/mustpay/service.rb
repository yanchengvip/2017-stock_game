module Mustpay
  module Service

    #mustpay 生成商户通过统一下单接口获取的预支付ID
    def self.generate_mustpay_prepay_id(params, options = {})
      params = {
          apps_id: MUSTAPAYCONFIG[:mustpay][:apps_id],
          mer_id: MUSTAPAYCONFIG[:mustpay][:mer_id]
      }.merge(params)
      sign_params = Mustpay::Sign.generate_mustpay_sign params
      mustpay_url = MUSTAPAYCONFIG[:mustpay][:gateway_url] + '?' + URI.encode(sign_params[:sign_str]) + "&sign=#{ERB::Util.url_encode(sign_params[:sign])}" + "&sign_type=RSA"
      response = HTTParty.get(mustpay_url) #{"status":"1","errorCode":"0","msg":"","info":{"prepay_id":"5cdefffb85884c7dafaeb22b227c0979"},"token":null}
      prepay_id = response['info'].present? ? response['info']['prepay_id'] : ''
    end



  end
end
