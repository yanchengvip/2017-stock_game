require 'test_helper'

class DiamondTradesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @diamond_trade = diamond_trades(:one)
  end

  test "should get index" do
    get diamond_trades_url
    assert_response :success
  end

  test "should get new" do
    get new_diamond_trade_url
    assert_response :success
  end

  test "should create diamond_trade" do
    assert_difference('DiamondTrade.count') do
      post diamond_trades_url, params: { diamond_trade: { booking_trade_id: @diamond_trade.booking_trade_id, business_type: @diamond_trade.business_type, sale_diamond_id: @diamond_trade.sale_diamond_id, total_count: @diamond_trade.total_count, total_price: @diamond_trade.total_price, user_id: @diamond_trade.user_id } }
    end

    assert_redirected_to diamond_trade_url(DiamondTrade.last)
  end

  test "should show diamond_trade" do
    get diamond_trade_url(@diamond_trade)
    assert_response :success
  end

  test "should get edit" do
    get edit_diamond_trade_url(@diamond_trade)
    assert_response :success
  end

  test "should update diamond_trade" do
    patch diamond_trade_url(@diamond_trade), params: { diamond_trade: { booking_trade_id: @diamond_trade.booking_trade_id, business_type: @diamond_trade.business_type, sale_diamond_id: @diamond_trade.sale_diamond_id, total_count: @diamond_trade.total_count, total_price: @diamond_trade.total_price, user_id: @diamond_trade.user_id } }
    assert_redirected_to diamond_trade_url(@diamond_trade)
  end

  test "should destroy diamond_trade" do
    assert_difference('DiamondTrade.count', -1) do
      delete diamond_trade_url(@diamond_trade)
    end

    assert_redirected_to diamond_trades_url
  end
end
