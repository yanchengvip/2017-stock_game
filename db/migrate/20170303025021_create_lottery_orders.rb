class CreateLotteryOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :lottery_orders, comment: "抽奖订单" do |t|
      t.integer :lottery_id, comment: "抽奖表id"
      t.integer :user_id, comment: "用户id"
      t.string :request_ip, comment: "用户ip"
      t.integer :total_count,default: 0, comment: "购买总数"
      t.decimal :total_price, precision: 10, scale: 2,default: 0, comment: "总价"
      t.boolean :is_win,default: false, comment: "是否中奖"
      t.integer :status,default:0, comment: "订单状态 -1:已作废 0:未发货,1:已发货,2:已兑换收益,3:待发货"
      t.integer :address_id, comment: "收货地址id"

      t.timestamps
    end
  end
end
