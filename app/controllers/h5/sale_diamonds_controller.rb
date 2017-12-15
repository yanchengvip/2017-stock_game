class H5::SaleDiamondsController < ::ApplicationController
  before_action :set_sale_diamond, only: [:show, :buy, :sell, :shorting, :close]
  # skip_before_action :authenticate_user
  skip_before_action :verify_signature
  skip_before_filter :verify_authenticity_token
  skip_before_action :authenticate_user, only: [:update_diamonds_price]

  #主动更新钻石价格
  def update_diamonds_price
    SaleDiamond.update_all_price
    render json: {status: 200}
  end

  def kline
    kline_data = Dialink::Kline.kline_data(params["stock_code"])
    render json: {status: 200, data: kline_data}
  end

  def pre
    if params[:id]
      sale_diamond = SaleDiamond.where("is_published = true and id < ?", params[:id].to_i).order(id: :desc).limit(1).first
      sale_diamond = SaleDiamond.where("is_published = true").last unless sale_diamond
      redirect_to "/h5/sale_diamonds/#{sale_diamond.id}"
    else
      redirect_to "/"
    end
  end

  def next
    if params[:id]
      sale_diamond = SaleDiamond.where("is_published = true and id > ?", params[:id].to_i).order(:id).limit(1).first
      sale_diamond = SaleDiamond.where("is_published = true and id < ?", params[:id].to_i).order(:id).limit(1).first unless sale_diamond
      redirect_to "/h5/sale_diamonds/#{sale_diamond.id}"
    else
      redirect_to "/"
    end
  end

  def diamond_history_price
    diamond_history_prices = SaleDiamond.diamond_history_price(params["id"])
    render json:{diamond_history_prices: diamond_history_prices}
  end

  # GET /sale_diamonds/1
  # GET /sale_diamonds/1.json
  def show
    @title = "行情"
    @shorting_diamond_trades = DiamondTrade.includes(:sale_diamond).where(close_shorting_status: [0, 1], user_id: current_user.id, bussiness_type: 3, sale_diamond_id: @sale_diamond.id)
    @charts = {
      min: (Time.now.beginning_of_day + 9.5 * 3600).to_i * 1000,
      max: (Time.now.beginning_of_day + 15 * 3600).to_i * 1000,
      midday: (Time.now.beginning_of_day + 11.5 * 3600).to_i * 1000,
    }
    # @sale_diamond = SaleDiamond.find(params[:sale_diamond_id])
    if @sale_diamond
      hold_diamonds = HoldDiamond.user_diamonds(current_user.id, @sale_diamond.id)
      if hold_diamonds.size > 0
        @hold_diamonds_info = {
          cn_name: @sale_diamond.cn_name,
          exchange_name: @sale_diamond.exchange_name,
          exchange_code: @sale_diamond.exchange_code,
          total_count: hold_diamonds.size,
          available_count: hold_diamonds.select{|x|x.created_at <  (Date.today - SYSTEMCONFIG[:trade_time_interval_days]).to_time.at_end_of_day && x.status == 0}.size,
          avg_price: hold_diamonds.inject(0){|sum, x| sum += x.buy_price} /  hold_diamonds.size,
          market_price: Dialink::DiamondPriceHistory.market_price(@sale_diamond.exchange_code)
        }
      end
      @booking_trades = current_user.booking_trades.where(sale_diamond_id: @sale_diamond.id).where("created_at > ?", Time.now.at_beginning_of_day).order("created_at desc")
      @diamond_history_prices = SaleDiamond.diamond_history_price(@sale_diamond.exchange_code )
      @kline_data = Dialink::Kline.kline_data(@sale_diamond.exchange_code)
      # @diamond_history_close_prices = Dialink::Kline.last_close_price(@sale_diamond.exchange_code, 100)
      respond_to do |format|
        format.html
        format.json { render json: {data: { sale_diamond: @sale_diamond, shorting_diamond_trades: @shorting_diamond_trades, trade_time_interval_days: SYSTEMCONFIG[:trade_time_interval_days], charts: @charts, hold_diamonds_info: @hold_diamonds_info.presence, booking_trades: @booking_trades, diamond_history_prices: @diamond_history_prices, kline_data: @kline_data}, status: 200, msg: '操作成功'} }
      end
    else
      respond_to do |format|
        format.html { redirect_to "/" }
        format.json { render json: {status: 500, msg: '数据错误', data: {}} }
      end
    end
  end

  def buy
    @title = "交易"
    @sale_diamonds = SaleDiamond.is_published
    @buy_count = (current_user.available_gold / @sale_diamond.current_price).floor
    @data = {sale_diamonds: @sale_diamonds, buy_count: @buy_count, sale_diamond: @sale_diamond}
    respond_to do |format|
      format.html {  }
      format.json { render json: {data: {sale_diamonds: @sale_diamonds, available_gold: current_user.reload.available_gold, buy_count: @buy_count, sale_diamond: @sale_diamond}, status: 200, msg: '操作成功'} }
    end
  end

  def sell
    @title = "交易"
    @sale_diamonds = SaleDiamond.is_published
    @available_diamonds =  HoldDiamond.available_diamonds(current_user.id, @sale_diamond.id)
    @data = {sale_diamonds: @sale_diamonds, available_diamonds: @available_diamonds.count, sale_diamond: @sale_diamond}
    respond_to do |format|
      format.html {  }
      format.json { render json: {data: {sale_diamonds: @sale_diamonds, available_diamonds: @available_diamonds.count, sale_diamond: @sale_diamond}, status: 200, msg: '操作成功'} }
    end
  end

  def shorting
    @title = "交易"
    @sale_diamonds = SaleDiamond.is_published
    @shorting_count = (current_user.available_gold / @sale_diamond.current_price).floor
    @data = {sale_diamonds: @sale_diamonds, shorting_count: @shorting_count, sale_diamond: @sale_diamond}
    respond_to do |format|
      format.html {  }
      format.json { render json: {data: {sale_diamonds: @sale_diamonds, available_gold: current_user.reload.available_gold,shorting_count: @shorting_count, sale_diamond: @sale_diamond}, status: 200, msg: '操作成功'} }
    end
  end

  def close
    @title = "交易"
    @diamond_trade = DiamondTrade.find(params[:diamond_trade_id])
    @sale_diamonds = SaleDiamond.is_published
    respond_to do |format|
      format.html
      format.json { render json: {data: {diamond_trade: @diamond_trade, sale_diamonds: @sale_diamonds}, status: 200, msg: '操作成功'}}
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sale_diamond
      @sale_diamond = SaleDiamond.find(params[:id])
    end
end
