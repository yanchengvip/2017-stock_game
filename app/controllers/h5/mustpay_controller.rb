class H5::MustpayController < ApplicationController
  skip_before_action :authenticate_user, only: [:notify]
  skip_before_action :verify_authenticity_token, only: [:notify]
  skip_before_action :verify_signature, only: [:notify]

  def pay_order
    @title = '支付运费'
    @lottery_order = LotteryOrder.includes(:lottery,:product).find(params[:lottery_order_id])
    prepay_id = PayRecord.generate_prepay_id @lottery_order
    @mustpay = {apps_id: MUSTAPAYCONFIG[:mustpay][:apps_id],prepay_id: prepay_id}
  end


  #验签
  def notify
    mer_id = MUSTAPAYCONFIG[:mustpay][:mer_id].to_s
    apps_id = MUSTAPAYCONFIG[:mustpay][:apps_id].to_s
    flag = false
    is_verify = Mustpay::Sign.notify? params
    if params[:out_trade_no].include?('R') && is_verify
      #竞赛排行支付订单
      # order = RankingConfigWinOrder.includes(:user).where(code: params[:out_trade_no]).first

    elsif params[:out_trade_no].include?('L') && is_verify && params[:mer_id] == mer_id && params[:apps_id] == apps_id
      #夺宝产品支付订单
      lottery_order = LotteryOrder.includes(:user).where(code: params[:out_trade_no]).first
      if lottery_order
        order_postage = (lottery_order.product.postage.to_f * 100).to_i
        if params[:total_fee].to_i != order_postage
          render json: {status: 'error',msg: "支付金额与订单金额不符合"} and return
        end
        ActiveRecord::Base.transaction do
          if ![-1,2].include?(lottery_order.status.to_i)
            lottery_order.update_attributes!(status: 3)
          end
          lottery_order.lottery.update_attributes!(take_award: true)
          PayRecord.create_mustpay_record(lottery_order, params)
          flag = 'success'
        end
      end
    elsif params[:out_trade_no].include?('M') && params[:mer_id] == mer_id && params[:apps_id] == apps_id
      #充值现金订单
      p1 = params.merge(trade_status: 'TRADE_SUCCESS',total_amount: params[:total_fee].to_f/100,pay_types: 3)
      flag = ChargeOrder.pay_notify_handle p1
    end

    render json: flag
  end
end
