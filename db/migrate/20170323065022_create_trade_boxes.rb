class CreateTradeBoxes < ActiveRecord::Migration[5.0]
  def change
    create_table :trade_boxes, comment: "交易赠送宝箱" do |t|
      t.integer :user_id, comment: "用户id"
      t.decimal :amount, comment: "宝箱虚拟金"
      t.string :day, comment: "天"
      t.timestamps
    end
    add_index :trade_boxes, :user_id
    add_index :trade_boxes, :day
  end
end
