require 'test_helper'

class HoldDiamondsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hold_diamond = hold_diamonds(:one)
  end

  test "should get index" do
    get hold_diamonds_url
    assert_response :success
  end

  test "should get new" do
    get new_hold_diamond_url
    assert_response :success
  end

  test "should create hold_diamond" do
    assert_difference('HoldDiamond.count') do
      post hold_diamonds_url, params: { hold_diamond: { buy_price: @hold_diamond.buy_price, buy_time: @hold_diamond.buy_time, diamond_trade_id: @hold_diamond.diamond_trade_id, profit: @hold_diamond.profit, sale_diamond_id: @hold_diamond.sale_diamond_id, sell_price: @hold_diamond.sell_price, sell_time: @hold_diamond.sell_time, status: @hold_diamond.status, user_id: @hold_diamond.user_id } }
    end

    assert_redirected_to hold_diamond_url(HoldDiamond.last)
  end

  test "should show hold_diamond" do
    get hold_diamond_url(@hold_diamond)
    assert_response :success
  end

  test "should get edit" do
    get edit_hold_diamond_url(@hold_diamond)
    assert_response :success
  end

  test "should update hold_diamond" do
    patch hold_diamond_url(@hold_diamond), params: { hold_diamond: { buy_price: @hold_diamond.buy_price, buy_time: @hold_diamond.buy_time, diamond_trade_id: @hold_diamond.diamond_trade_id, profit: @hold_diamond.profit, sale_diamond_id: @hold_diamond.sale_diamond_id, sell_price: @hold_diamond.sell_price, sell_time: @hold_diamond.sell_time, status: @hold_diamond.status, user_id: @hold_diamond.user_id } }
    assert_redirected_to hold_diamond_url(@hold_diamond)
  end

  test "should destroy hold_diamond" do
    assert_difference('HoldDiamond.count', -1) do
      delete hold_diamond_url(@hold_diamond)
    end

    assert_redirected_to hold_diamonds_url
  end
end
