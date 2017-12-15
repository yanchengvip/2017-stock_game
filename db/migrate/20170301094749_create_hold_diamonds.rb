class CreateHoldDiamonds < ActiveRecord::Migration[5.0]
  def change
    create_table :hold_diamonds, comment: "持有钻石表" do |t|
      t.integer :sale_diamond_id, default: 0, comment: "钻石id"
      t.decimal :buy_price, precision: 10, scale: 2, default: 0, comment: "买入价"
      t.decimal :sell_price, precision: 10, scale: 2, default: 0, comment: "卖出价"
      t.datetime :sell_time, comment: "卖出时间"
      t.datetime :buy_time, comment: "买入时间"
      t.integer :status, default: 0, comment: "状态 0 持有 1 挂单 2 成交"
      t.integer :diamond_trade_id, default: 0, comment: "钻石订单_id"
      t.integer :user_id, default: 0, comment: "用户id"
      t.decimal :profit, precision: 10, scale: 2, comment: "利润"

      t.timestamps
    end
    add_index :hold_diamonds, [:created_at]
  end
end
