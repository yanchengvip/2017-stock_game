class H5::HoldDiamondsController < ApplicationController
  skip_before_action :verify_signature
  skip_before_filter :verify_authenticity_token
  # GET /diamond_trades
  # GET /diamond_trades.json
  def index
    @title = "交易"
    @sale_diamonds_price =SaleDiamond.current_prices
    @sale_diamond = SaleDiamond.where(is_published: true).first
    @hold_diamonds_data = {hold_diamonds_info: HoldDiamond.position_info(current_user), diamond_trades_info: DiamondTrade.includes(:sale_diamond).where(user_id: current_user.id, bussiness_type: 3, close_shorting_status: [0,1]).as_json(), sale_diamonds_price: @sale_diamonds_price}
    respond_to do |format|
      format.html {}
      format.json {render json: {data: @hold_diamonds_data, status: 200, msg: '操作成功'}}
    end
  end


end
