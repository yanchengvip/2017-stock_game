class AddTotalDiamondCoinToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :total_diamond_coin, :decimal, precision: 10, scale: 2, default: 0, comment: "钻石币"
  end
end
