class H5::BookingTradesController < ApplicationController
  before_action :set_booking_trade, only: [:show, :edit, :update, :destroy, :cancle]
  skip_before_action :verify_signature
  skip_before_filter :verify_authenticity_token

  def cancle
    res = @booking_trade.cancle
    render json: res
  end

  # GET /booking_trades
  # GET /booking_trades.json
  def index
    @title = "交易"
    @sale_diamond = SaleDiamond.where(is_published: true).first
    @booking_trades = $cache.fetch("booking_trades_#{current_user.id}_#{params[:page]}", 1){
      BookingTrade.includes(:sale_diamond).where("user_id = ? and created_at > ?", current_user.id, Date.today.to_time).where(status: [0, -1]).order("id desc").paginate(:page => params[:page] || 1).to_a
    }
    @sale_diamonds_price =SaleDiamond.current_prices
    @hold_diamonds = HoldDiamond.can_sell?.where(user_id: current_user.id, status: 0).group(:sale_diamond_id).count
    respond_to do |format|
      format.html {render "h5/hold_diamonds/index"}
      format.json {render json: {data: @booking_trades, status: 200, msg: '操作成功'}}
    end
  end

  # GET /booking_trades/1
  # GET /booking_trades/1.json
  def show
  end


  # POST /booking_trades
  # POST /booking_trades.json
  #  sale_diamond_id: integer, total_count: integer bussiness_type: integer, booking_price: decimal,
  def create
    seconds = Time.now - Time.now.beginning_of_day
    if(seconds < 7 * 3600 || seconds > 23 * 3600 )
      res = {status: 500, msg: "交易时间为早7点至晚23点", data: {}}
    else
      res = BookingTrade.create_booking_trade(booking_trade_params, current_user)
    end
    render json: res
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking_trade
      @booking_trade = BookingTrade.where(user_id: current_user.id).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_trade_params
      params.require(:booking_trade).permit(:sale_diamond_id, :total_count, :bussiness_type, :booking_price, :diamond_trade_id)
    end
end
