class CreateDiamondTrades < ActiveRecord::Migration[5.0]
  def change
    create_table :diamond_trades, comment: "钻石订单表" do |t|
      t.integer :booking_trade_id, default: 0, comment: "挂单id"
      t.integer :user_id, default: 0, comment: "用户id"
      t.integer :sale_diamond_id, default: 0, comment: "钻石id"
      t.integer :business_type, default: 0, comment: "1买 2 卖"
      t.integer :total_count, default: 0, comment: "钻石数量"
      t.decimal :total_price, precision: 10, scale: 2, default: 0, comment: "总价"

      t.timestamps
    end
  end
end
