#支付宝、微信支付记录
#pay_type: 0: 无,1:支付宝支付,2:微信支付,3:mustpay平台的微信服务号支付
#trade_status 1:交易创建,2:交易关闭,3:支付成功,4:交易完成
class PayRecord < ApplicationRecord
  belongs_to :table, polymorphic: true
  validates_uniqueness_of :out_trade_no, scope: [:trade_status]

  #支付宝保存支付记录
  def self.create_alipay_record(obj, params)
    #{"total_amount"=>"0.01", "buyer_id"=>"2088012338474860", "trade_no"=>"2017041721001004860206606887",
    # "notify_time"=>"2017-04-17 11:23:27", "subject"=>"测试数据", "sign_type"=>"RSA2", "buyer_logon_id"=>"zqa***@163.com",
    # "auth_app_id"=>"201704100623", "charset"=>"UTF-8", "notify_type"=>"trade_status_sync", "invoice_amount"=>"0.01",
    # "out_trade_no"=>"L201704131504281122", "trade_status"=>"TRADE_SUCCESS", "gmt_payment"=>"2017-04-17 10:59:09",
    # "version"=>"1.0", "point_amount"=>"0.00", "sign"=>"RTvY3Pv7nCgC1pg710QaSFSqWh24pRVhRIdZVDjrZtV30p0PysisqGkk2PHFoaKtXstPd8Lnm1vac/UuCZwQY1Wg2PFCaQXYX3soiGtTsmJGHYfUztfG9vIFwCNlaKngpGU1bQXfwrE3nZOqyAJFYv5Zq20ey5hjEHWf6tiUjHsixT1Wim2phIeBSBt8K8xZ6uP41nH9MYNSkVKJosOanx+WFMs8E+aG3WaKPhpsMpEnH7XuSYzYfS3wueo5wFW8Z9wGAHpCBhrHZMxuBXGYvt0vxZ6O1uR1wvA3XTpsyF6CwlFyD9ayUfxoNzaTN8e2o0d3pqRFosIUSyH/eTuytw==",
    # "gmt_create"=>"2017-04-17 10:59:09", "buyer_pay_amount"=>"0.01", "receipt_amount"=>"0.01", "fund_bill_list"=>"[{\"amount\":\"0.01\",\"fundChannel\":\"ALIPAYACCOUNT\"}]",
    # "app_id"=>"2017041006617723", "seller_id"=>"2088621733420677",
    # "notify_id"=>"74f8268cb7604891390016a5eac5a04mmy", "seller_email"=>"vip@iuzuan.com"}
    case params[:trade_status]
      when 'WAIT_BUYER_PAY'
        trade_status = 1 #交易创建
      when 'TRADE_CLOSED'
        trade_status = 2 #交易关闭
      when 'TRADE_SUCCESS'
        trade_status = 3 #支付成功
      when 'TRADE_FINISHED'
        trade_status = 4 #交易完成

      else
        trade_status = 0
    end
    obj.pay_records.create!(user_id: obj.user.id, pay_type: 1, notify_time: params[:notify_time],
                            trade_no: params[:trade_no], out_trade_no: params[:out_trade_no],
                            buyer_id: params[:buyer_id], buyer_logon_id: params[:buyer_logon_id],
                            seller_id: params[:seller_id], seller_email: params[:seller_email],
                            trade_status: trade_status, total_amount: params[:total_amount],
                            receipt_amount: params[:receipt_amount], buyer_pay_amount: params[:buyer_pay_amount])


  end

  #支付宝支付地址
  def self.generate_alipay_wap_url(lottery_order)
    params ={
        return_url: ALIPAYCONFIG[:alipay][:host] + "h5/lotteries/#{lottery_order.lottery.id}",
        notify_url: ALIPAYCONFIG[:alipay][:host] + 'h5/alipay/notify',
        biz_content: {"subject": "商品邮费", "out_trade_no": lottery_order.code,
                      "total_amount": lottery_order.product.postage.to_f,
                      "product_code": "QUICK_WAP_PAY"}.to_json
    }

    url = Myalipay::Wap::Service.create_alipay_trade_wap_pay_url params

  end


  def self.generate_alipay_wap_url2 params
    params ={
        return_url: ALIPAYCONFIG[:alipay][:host] + params[:return_url],
        notify_url: ALIPAYCONFIG[:alipay][:host] + params[:notify_url],
        biz_content: params[:biz_content].to_json
    }

    url = Myalipay::Wap::Service.create_alipay_trade_wap_pay_url params
  end

  #Mustpay支付地址
  def self.generate_prepay_id(lottery_order)
    params ={
        return_url: MUSTAPAYCONFIG[:mustpay][:host] + "h5/lotteries/#{lottery_order.lottery.id}",
        notify_url: MUSTAPAYCONFIG[:mustpay][:host] + 'h5/mustpay/notify',
        subject: '商品邮费',
        body: '商品邮费',
        out_trade_no: lottery_order.code,
        total_fee: (lottery_order.product.postage.to_f * 100).to_i
    }

    prepay_id = Mustpay::Service.generate_mustpay_prepay_id params
  end

  def self.generate_prepay_id2(params)
    params ={
        return_url: MUSTAPAYCONFIG[:mustpay][:host] + params[:return_url],
        notify_url: MUSTAPAYCONFIG[:mustpay][:host] + params[:notify_url],
        subject: params[:subject],
        body: params[:body],
        out_trade_no: params[:out_trade_no],#订单号
        total_fee: (params[:total_fee].to_f * 100).to_i #订单金额 分
    }

    prepay_id = Mustpay::Service.generate_mustpay_prepay_id params
  end

  #mustpay微信支付
  def self.create_mustpay_record(obj, params)
    obj.pay_records.create!(user_id: obj.user.id, pay_type: 3, notify_time: params[:pay_time],
                            trade_no: params[:trade_no], out_trade_no: params[:out_trade_no],
                            trade_status: 3, total_amount: params[:total_fee].to_f/100)


  end

end