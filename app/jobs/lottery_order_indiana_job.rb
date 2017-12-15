class LotteryOrderIndianaJob < ApplicationJob
  queue_as :lottery_orders_indiana
  def perform(lottery_order_id)
    lottery_order = LotteryOrder.find(lottery_order_id)
    lottery = lottery_order.lottery

    ActiveRecord::Base.transaction do
      if($redis.llen("lettery_order_items_#{lottery.id}") == 0)
        if($redis.sadd("lettery_order_items_initing_#{lottery.id}", lottery.id))
          lottery_codes = LotteryOrderItem.where(lottery_id: lottery.id).pluck(:lottery_code).map(&:to_i)
          puts "*"*100
          puts lottery_codes.count
          left_lottery_codes = (LotteryOrderItem::BEGINNUMBER ... LotteryOrderItem::BEGINNUMBER + lottery.total_count).to_a.shuffle - lottery_codes
          puts "-"*100
          puts left_lottery_codes.count
          left_lottery_codes.each_slice(100).each do |x|
            $redis.lpush("lettery_order_items_#{lottery.id}", x)
          end
          $redis.expire("lettery_order_items_initing_#{lottery.id}", 1)
        end
        LotteryOrderIndianaJob.delay_for(10.seconds).perform_now(lottery_order_id)
        return true
      else
        (1..lottery_order.total_count).each do |i|
          lottery_code = $redis.lpop("lettery_order_items_#{lottery.id}")
          if lottery_code
            # lottery_order.lottery_order_items.create!(lottery_id: lottery_order.lottery_id, user_id: lottery_order.user_id, request_ip: lottery_order.request_ip, lottery_code: lottery_code )
            puts lottery_code
            if lottery_order.total_count < 10
              LotteryOrderItemJob.perform_now(lottery_order_id: lottery_order.id, lottery_id: lottery_order.lottery_id, user_id: lottery_order.user_id, request_ip: lottery_order.request_ip, lottery_code: lottery_code )
            else
              LotteryOrderItemJob.delay_for(1.seconds).perform_now(lottery_order_id: lottery_order.id, lottery_id: lottery_order.lottery_id, user_id: lottery_order.user_id, request_ip: lottery_order.request_ip, lottery_code: lottery_code )
            end
          end
        end
        sales_count = lottery.total_count - $redis.llen("lettery_order_items_#{lottery.id}")
        lottery.update_attributes!(sales_count: sales_count, progress:  sales_count.to_f / lottery.total_count)
        return true
      end
    end
  end
end
