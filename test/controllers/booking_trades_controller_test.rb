require 'test_helper'

class BookingTradesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @booking_trade = booking_trades(:one)
  end

  test "should get index" do
    get booking_trades_url
    assert_response :success
  end

  test "should get new" do
    get new_booking_trade_url
    assert_response :success
  end

  test "should create booking_trade" do
    assert_difference('BookingTrade.count') do
      post booking_trades_url, params: { booking_trade: { booking_price: @booking_trade.booking_price, bussiness_type: @booking_trade.bussiness_type, deposit: @booking_trade.deposit, sale_diamond_id: @booking_trade.sale_diamond_id, status: @booking_trade.status, total_count: @booking_trade.total_count, user_id: @booking_trade.user_id } }
    end

    assert_redirected_to booking_trade_url(BookingTrade.last)
  end

  test "should show booking_trade" do
    get booking_trade_url(@booking_trade)
    assert_response :success
  end

  test "should get edit" do
    get edit_booking_trade_url(@booking_trade)
    assert_response :success
  end

  test "should update booking_trade" do
    patch booking_trade_url(@booking_trade), params: { booking_trade: { booking_price: @booking_trade.booking_price, bussiness_type: @booking_trade.bussiness_type, deposit: @booking_trade.deposit, sale_diamond_id: @booking_trade.sale_diamond_id, status: @booking_trade.status, total_count: @booking_trade.total_count, user_id: @booking_trade.user_id } }
    assert_redirected_to booking_trade_url(@booking_trade)
  end

  test "should destroy booking_trade" do
    assert_difference('BookingTrade.count', -1) do
      delete booking_trade_url(@booking_trade)
    end

    assert_redirected_to booking_trades_url
  end
end
