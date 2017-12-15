module Myalipay
  module Wap
    module Notify

      def self.wap_notify params
        params.stringify_keys
        params.delete('sign_type')
        params.delete('controller')
        params.delete('action')
        sign =  params.delete('sign')
        sign = Base64.decode64(sign)
        sign_str = Myalipay::Utils.params_to_string params
        digest = OpenSSL::Digest::SHA256.new
        pkey = OpenSSL::PKey::RSA.new(Base64.decode64(ALIPAYCONFIG[:alipay][:alipay_public_key]))
        pkey.verify(digest, sign, sign_str)
      end
      #{"total_amount"=>"0.01", "buyer_id"=>"2088102170372427", "trade_no"=>"2017041721001004420200352846",
      # "notify_time"=>"2017-04-17 14:01:59", "subject"=>"测试数据", "sign_type"=>"RSA2", "buyer_logon_id"=>"qbn***@sandbox.com",
      # "auth_app_id"=>"201608146859", "charset"=>"UTF-8", "notify_type"=>"trade_status_sync", "invoice_amount"=>"0.01",
      # "out_trade_no"=>"L20170413150428110212013", "trade_status"=>"TRADE_SUCCESS",
      # "gmt_payment"=>"2017-04-17 14:01:58", "version"=>"1.0", "point_amount"=>"0.00",
      # "sign"=>"VVnXYZ2IzZx2Wy/odCWY+3V2+rGfC5Nw7Z9RY9PjeyKR3VJLws5oxDftWurj7ubk4OGJg/ZMZx0iemTsLd4Sa5HEucfrzX47F/5HK7P+FGx4SQiKkEBCZolCMgnhK08Bh6tcErxJHjd6/1E0tCzmJYmjrSB45v12dbfgUlMm1xN44/ifTLgr7YPNw3foEgqW+jtecRiJCkU2GpB0C7xS6NHUcjgU1l2qifau2BFvm/g7uZRduVd5X0le02xYk8383P+4t2sh5zz7m5LyHWbs273N7ZNAKJqM9erC0LaFwF987LIGinkqD7hqbKB+LWWGW8Qn3MoQT9lP5q4ut1ME5w==",
      # "gmt_create"=>"2017-04-17 14:01:57", "buyer_pay_amount"=>"0.01", "receipt_amount"=>"0.01",
      # "fund_bill_list"=>"[{\"amount\":\"0.01\",\"fundChannel\":\"ALIPAYACCOUNT\"}]", "app_id"=>"2016080200146859",
      # "seller_id"=>"2088102169559754", "notify_id"=>"36ab2a276c8f8396fc4c3f3e052cdfej8q",
      # "seller_email"=>"unomjp1680@sandbox.com"}
    end
  end
end
