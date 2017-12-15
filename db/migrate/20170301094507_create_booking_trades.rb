class CreateBookingTrades < ActiveRecord::Migration[5.0]
  def change
    create_table :booking_trades, comment: "挂单表" do |t|
      t.integer :sale_diamond_id, default: 0, comment: "钻石id"
      t.integer :total_count, default: 0, comment: "总数"
      t.integer :user_id, default: 0, comment: "用户id"
      t.integer :bussiness_type, default: 0, comment: "买1 卖 2"
      t.decimal :booking_price, precision: 10, scale: 2, comment: "挂单价"
      t.integer :status, default: 0, comment: "0 挂单 1 成交 1 撤单"

      t.timestamps
    end
  end
end
