class CreateLotteryOrderItems < ActiveRecord::Migration[5.0]
  def change
    create_table :lottery_order_items, comment: "抽奖订单明细" do |t|
      t.integer :lottery_id, comment: "抽奖id"
      t.integer :lottery_order_id, comment: "抽奖订单id"
      t.integer :user_id, comment: "用户id"
      t.string :lottery_code, comment: "抽奖编码"
      t.string :request_ip, comment: "用户ip"
      t.boolean :is_win,default: false, comment: "是否中奖"

      t.timestamps
    end
  end
end
