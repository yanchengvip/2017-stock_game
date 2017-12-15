class AddProfitToDiamondTrades < ActiveRecord::Migration[5.0]
  def change
    add_column :diamond_trades, :profit, :decimal, precision: 10, scale: 2, default:0, comment: "该笔交易总收益"
  end
end
