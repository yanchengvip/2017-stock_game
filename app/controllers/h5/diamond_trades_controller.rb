class H5::DiamondTradesController < ApplicationController
  before_action :set_diamond_trade, only: [:show]
  skip_before_action :verify_signature
  skip_before_filter :verify_authenticity_token
  # GET /diamond_trades
  # GET /diamond_trades.json
  def index
    @title = "收益记录"
    @sale_diamond = SaleDiamond.where(is_published: true).first
    # @diamond_trades = current_user.diamond_trades.order("id desc").paginate(:page => params[:page] || 1)
    @diamond_trades = $cache.fetch("diamond_trades_#{current_user.id}_#{params[:page]}", 5){
      DiamondTrade.where(user_id: current_user.id).order("id desc").paginate(:page => params[:page] || 1).as_json
    }
    @hold_diamonds = HoldDiamond.can_sell?.where(user_id: current_user.id, status: 0).group(:sale_diamond_id).count
    respond_to do |format|
      format.html {}
      format.json {render json: {data: {diamond_trades: @diamond_trades, hold_diamonds: @hold_diamonds}, status: 200, msg: '操作成功'}}
    end
  end

  # # GET /diamond_trades/1
  # # GET /diamond_trades/1.json
  # def show
  # end

  # POST /diamond_trades
  # POST /diamond_trades.json
  # def create
  #   @diamond_trade = DiamondTrade.new(diamond_trade_params)
  #   respond_to do |format|
  #     if @diamond_trade.save
  #       format.html { redirect_to @diamond_trade, notice: 'Diamond trade was successfully created.' }
  #       format.json { render :show, status: :created, location: @diamond_trade }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @diamond_trade.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diamond_trade
      @diamond_trade = DiamondTrade.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def diamond_trade_params
      params.require(:diamond_trade).permit(:booking_trade_id, :user_id, :sale_diamond_id, :bussiness_type, :total_count, :total_price)
    end
end
