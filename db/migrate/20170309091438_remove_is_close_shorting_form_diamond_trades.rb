class RemoveIsCloseShortingFormDiamondTrades < ActiveRecord::Migration[5.0]
  def change
    remove_column :diamond_trades, :is_close_shorting
  end
end
