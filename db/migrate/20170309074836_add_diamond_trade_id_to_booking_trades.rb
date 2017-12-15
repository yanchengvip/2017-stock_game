class AddDiamondTradeIdToBookingTrades < ActiveRecord::Migration[5.0]
  def change
    add_column :booking_trades, :diamond_trade_id, :integer
  end
end
