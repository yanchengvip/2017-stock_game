class AddFeeToDiamondTrades < ActiveRecord::Migration[5.0]
  def change
    add_column :diamond_trades, :fee, :decimal, precision: 10, scale: 2, default:0, comment: "手续费"
  end
end
