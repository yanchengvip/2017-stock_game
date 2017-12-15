class LotteryOrderItemJob < ApplicationJob
  queue_as :lottery_order_item
  def perform(json)
    LotteryOrderItem.create!(json)
  end
end
