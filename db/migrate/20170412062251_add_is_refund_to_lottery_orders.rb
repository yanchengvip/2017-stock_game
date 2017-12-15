class AddIsRefundToLotteryOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :lottery_orders, :is_refund, :boolean, default: false, comment: '是否退款'
  end
end
