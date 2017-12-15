require 'test_helper'

class SaleDiamondsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sale_diamond = sale_diamonds(:one)
  end

  test "should get index" do
    get sale_diamonds_url
    assert_response :success
  end

  test "should get new" do
    get new_sale_diamond_url
    assert_response :success
  end

  test "should create sale_diamond" do
    assert_difference('SaleDiamond.count') do
      post sale_diamonds_url, params: { sale_diamond: { change_price: @sale_diamond.change_price, change_price_persent: @sale_diamond.change_price_persent, clarity: @sale_diamond.clarity, color: @sale_diamond.color, current_price: @sale_diamond.current_price, current_price: @sale_diamond.current_price, exchange_code: @sale_diamond.exchange_code, exchange_name: @sale_diamond.exchange_name, idex_trading_volume: @sale_diamond.idex_trading_volume, is_published: @sale_diamond.is_published, max_size: @sale_diamond.max_size, min_size: @sale_diamond.min_size, name: @sale_diamond.name, opening_price: @sale_diamond.opening_price, price: @sale_diamond.price, price: @sale_diamond.price, rap_trading_volume: @sale_diamond.rap_trading_volume } }
    end

    assert_redirected_to sale_diamond_url(SaleDiamond.last)
  end

  test "should show sale_diamond" do
    get sale_diamond_url(@sale_diamond)
    assert_response :success
  end

  test "should get edit" do
    get edit_sale_diamond_url(@sale_diamond)
    assert_response :success
  end

  test "should update sale_diamond" do
    patch sale_diamond_url(@sale_diamond), params: { sale_diamond: { change_price: @sale_diamond.change_price, change_price_persent: @sale_diamond.change_price_persent, clarity: @sale_diamond.clarity, color: @sale_diamond.color, current_price: @sale_diamond.current_price, current_price: @sale_diamond.current_price, exchange_code: @sale_diamond.exchange_code, exchange_name: @sale_diamond.exchange_name, idex_trading_volume: @sale_diamond.idex_trading_volume, is_published: @sale_diamond.is_published, max_size: @sale_diamond.max_size, min_size: @sale_diamond.min_size, name: @sale_diamond.name, opening_price: @sale_diamond.opening_price, price: @sale_diamond.price, price: @sale_diamond.price, rap_trading_volume: @sale_diamond.rap_trading_volume } }
    assert_redirected_to sale_diamond_url(@sale_diamond)
  end

  test "should destroy sale_diamond" do
    assert_difference('SaleDiamond.count', -1) do
      delete sale_diamond_url(@sale_diamond)
    end

    assert_redirected_to sale_diamonds_url
  end
end
