class AddIsCloseShortingToDiamondTrades < ActiveRecord::Migration[5.0]
  def change
    add_column :diamond_trades, :is_close_shorting, :boolean, default:false, comment: "做空单是否平仓"
  end
end
