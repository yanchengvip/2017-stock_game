class AddCloseShortingStatusToDiamondTrades < ActiveRecord::Migration[5.0]
  def change
    add_column :diamond_trades, :close_shorting_status, :integer, default: 0, comment: " 平仓状态 0 未平仓 1 挂单 2平仓"
    add_index :diamond_trades, :close_shorting_status
  end
end
