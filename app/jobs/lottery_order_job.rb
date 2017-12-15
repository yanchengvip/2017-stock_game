class LotteryOrderJob < ApplicationJob
  queue_as :lottery_orders
  def perform(lottery_order_id)

    lottery_order = LotteryOrder.find(lottery_order_id)
    lottery = lottery_order.lottery
    ActiveRecord::Base.transaction do
      (1..lottery_order.total_count).to_a.reverse.each do  |index|
        lottery_order.lottery_order_items.create!(lottery_id: lottery_order.lottery_id, user_id: lottery_order.user_id, request_ip: lottery_order.request_ip,lottery_code: LotteryOrderItem::BEGINNUMBER + lottery.total_count - (lottery_order.redis_left_count + index) )
      end
      lottery.update_attributes!(sales_count: lottery.total_count - lottery_order.redis_left_count )
    end
  end
end
