class BookingTradeCheckJob < ApplicationJob
  queue_as :booking_trades

  def perform(booking_trade_id)
    booking_trade = BookingTrade.find(booking_trade_id)
    res = booking_trade.check_price
    puts [booking_trade_id, res]
    unless res
      BookingTradeCheckJob.delay_for(30.seconds).perform_now(booking_trade_id)
    end
  end

end
