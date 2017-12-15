class H5::AlipayController < ApplicationController
  skip_before_action :authenticate_user, only: [:notify, :test]
  skip_before_action :verify_authenticity_token, only: [:notify, :test]
  skip_before_action :verify_signature, only: [:notify, :test]


  #订单邮费支付
  def pay_extra
    @title = '支付运费'
    @lottery_order = LotteryOrder.includes(:lottery, :product).find(params[:lottery_order_id])
    @alipay_url = PayRecord.generate_alipay_wap_url @lottery_order
  end

  #支付宝异步通知接口
  def notify
    flag = false
    app_id = ALIPAYCONFIG[:alipay][:app_id].to_s
    is_verify = Myalipay::Wap::Notify.wap_notify params
    if params[:out_trade_no].include?('R') && is_verify
      #竞赛排行支付订单
      # order = RankingConfigWinOrder.includes(:user).where(code: params[:out_trade_no]).first

    elsif params[:out_trade_no].include?('L') && is_verify
      #夺宝产品支付订单
      lottery_order = LotteryOrder.includes(:user).where(code: params[:out_trade_no]).first
      if lottery_order
        ActiveRecord::Base.transaction do
          params_address = $redis.hgetall("lottery_order_address_#{lottery_order.id}")
          address = Address.create!(params_address)
          if ![-1,2].include?(lottery_order.status.to_i)
            lottery_order.update_attributes!(address_id: address.id, status: 3)
          end
          lottery_order.lottery.update_attributes!(take_award: true)
          PayRecord.create_alipay_record(lottery_order, params)
          flag = 'success'
        end
      end

    elsif params[:out_trade_no].include?('M') && is_verify && params[:app_id] == app_id
      #充值现金订单
      flag = ChargeOrder.pay_notify_handle params.merge(pay_types: 1)
    end


    render json: flag

  end


  def test
    params ={notify_url: ALIPAYCONFIG[:alipay][:host] + 'h5/alipay/notify',
             #return_url: ALIPAYCONFIG[:alipay][:host],
             biz_content: {"subject": "测试数据", "out_trade_no": "L1220170413150428110212013003",
                           "total_amount": 0.01, "product_code": "QUICK_WAP_PAY"}.to_json}
    url = Myalipay::Wap::Service.create_alipay_trade_wap_pay_url params
    redirect_to url
  end


end
