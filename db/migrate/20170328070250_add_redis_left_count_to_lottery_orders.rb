class AddRedisLeftCountToLotteryOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :lottery_orders, :redis_left_count, :integer, comment: "剩余数量", default: 0
  end
end
