class AddCodeToLotteryOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :lottery_orders, :code, :string, comment: '订单编号'
  end
end
