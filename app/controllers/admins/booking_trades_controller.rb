class Admins::BookingTradesController < Admins::ApplicationController
  before_action :set_booking_trade, only: [:show, :edit, :update, :destroy]

  # GET /booking_trades
  # GET /booking_trades.json
  def index
    @booking_trades = BookingTrade.all
  end

  # GET /booking_trades/1
  # GET /booking_trades/1.json
  def show
  end

  # GET /booking_trades/new
  def new
    @booking_trade = BookingTrade.new
  end

  # GET /booking_trades/1/edit
  def edit
  end

  # POST /booking_trades
  # POST /booking_trades.json
  def create
    @booking_trade = BookingTrade.new(booking_trade_params)

    respond_to do |format|
      if @booking_trade.save
        format.html { redirect_to @booking_trade, notice: 'Booking trade was successfully created.' }
        format.json { render :show, status: :created, location: @booking_trade }
      else
        format.html { render :new }
        format.json { render json: @booking_trade.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /booking_trades/1
  # PATCH/PUT /booking_trades/1.json
  def update
    respond_to do |format|
      if @booking_trade.update(booking_trade_params)
        format.html { redirect_to @booking_trade, notice: 'Booking trade was successfully updated.' }
        format.json { render :show, status: :ok, location: @booking_trade }
      else
        format.html { render :edit }
        format.json { render json: @booking_trade.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /booking_trades/1
  # DELETE /booking_trades/1.json
  def destroy
    @booking_trade.destroy
    respond_to do |format|
      format.html { redirect_to booking_trades_url, notice: 'Booking trade was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_booking_trade
    @booking_trade = BookingTrade.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def booking_trade_params
    params.require(:booking_trade).permit(:sale_diamond_id, :total_count, :user_id, :bussiness_type, :booking_price, :status, :deposit)
  end
end
