module Mustpay
  module Sign

    MUSTPAY_PRIVATE_KEY = Base64.decode64(MUSTAPAYCONFIG[:mustpay][:private_key]) #私钥
    MUSTPAY_RSA_PUBLIC_KEY = Base64.strict_decode64(MUSTAPAYCONFIG[:mustpay][:mustpay_public_key]) #mustpay公钥
    #rsa SHA1 签名
    def self.generate_mustpay_sign params
      hash_str = params.stringify_keys #{a:1,b:2} 转换成 {'a'= '1','b'='2'}
      sign_str = params_to_string hash_str
      rsa = OpenSSL::PKey::RSA.new(MUSTPAY_PRIVATE_KEY)
      sign = Base64.strict_encode64(rsa.sign('sha1', sign_str))
      {sign_str: sign_str, sign: sign}
    end



    #mustpay 验签
    def self.notify? params

      # {"apps_id"=>"d46d2fb7bfef4cf291719a1beab3cdca", "out_trade_no"=>"L155701224211404066", "trade_no"=>"efd4904bb81f43fa89a7acc423c62fa8", "mer_id"=>"17042114162206233", "total_fee"=>"1", "subject"=>"商品邮费", "body"=>"", "pay_name"=>"微信公众号支付me"=>"2017-04-24 11:31:47", "user_id"=>"", "extra"=>"", "sign"=>"WIaozivN/u5eR3MW+hh+I7apScsoMqaCdsOfqhW0ida4gQRAL44zRe+9eP3pF3a3cJc0V1FyLdLlvkt4/OustVzcreWCR9ghZ+xh2YwZEfoScwI2pVR7W5hWAaED4tC2BPiTLYuOaNo9OkRj4Nm27RPva72QoyeSQw1H6srqsu8=", "sign_type"=>"RSA"}
      params = stringify_keys params
      params.delete('sign_type')
      params.delete('controller')
      params.delete('action')
      sign =  params.delete('sign')
      sign = Base64.strict_decode64(sign)
      sign_str = params_to_string params
      rsa = OpenSSL::PKey::RSA.new(MUSTPAY_RSA_PUBLIC_KEY)
      rsa.verify('sha1', sign, sign_str)

    end


    def self.params_to_string(params)
      params.sort.map { |item| item.join('=') }.join('&')
    end

    def self.stringify_keys(hash)
      new_hash = {}
      hash.each do |key, value|
        new_hash[(key.to_s rescue key) || key] = value if value.present?
      end
      new_hash
    end

  end

end