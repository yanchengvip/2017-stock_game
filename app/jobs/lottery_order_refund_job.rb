class LotteryOrderRefundJob < ApplicationJob
  queue_as :lottery_order_refund
  def perform(lottery_id)
    lottery = Lottery.find(lottery_id)
    lottery.refund_diamond_account
  end
end
