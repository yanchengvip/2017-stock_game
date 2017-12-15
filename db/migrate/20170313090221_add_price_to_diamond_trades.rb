class AddPriceToDiamondTrades < ActiveRecord::Migration[5.0]
  def change
    add_column :diamond_trades, :price, :decimal, precision: 10, scale: 2, default: 0, comment: "单价"
  end
end
