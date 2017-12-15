class Admins::LotteryOrdersController < Admins::ApplicationController
  before_action :set_lottery_order, only: [:show, :update_status]

  before_action :set_product_menu_active
  before_action :product_side_menus

  def index
    @lottery_orders = LotteryOrder.includes(:product, :lottery)
                          .order(created_at: :desc)
                          .where('products.product_type': 1, is_win: true)
                          .paginate(:page => params[:page], :per_page => 20)
  end


  def show
    #订单详情
    @lottery_order = LotteryOrder.includes(:user, :lottery, :product, :lottery_order_items, :couriers, :address).find(params[:id])
    @lottery_code_all = @lottery_order.lottery_order_items.pluck(:lottery_code)
    @lottery_code_win = @lottery_order.lottery_order_items.where(is_win: true).pluck(:lottery_code)
    @user_address = @lottery_order.address
    @order_courier = @lottery_order.couriers.first
    #抽奖消耗的资金
    @total_price = @lottery_order.lottery_order_items.count * @lottery_order.lottery.price
    #交易记录
    @pay_record = PayRecord.where(out_trade_no: @lottery_order.code, trade_status: [3, 4]).first
  end


  def new
    @lottery_order = LotteryOrder.new
  end

  def edit
  end

  def update_status

    if [1].include? params[:status].to_i
      ActiveRecord::Base.transaction do
        @lottery_order.update_attributes!(status: params[:status])
        @lottery_order.lottery.update_attributes!(take_award: true)
      end
    end
    if [-1].include? params[:status].to_i
      ActiveRecord::Base.transaction do
        @lottery_order.update_attributes!(status: params[:status])
        @lottery_order.lottery.update_attributes!(take_award: false)
      end
    end
    courier_params = {courier_name: params[:courier_name], courier_no: params[:courier_no]}
    address_params = {user_name: params[:user_name], phone: params[:user_phone],
                      postcode: params[:postcode], address: params[:address]}
    if params[:is_add_address].to_i == 1
      #如果用户没有地址，联系用户保存新地址
      address = @lottery_order.user.addresses.create(address_params)
      @lottery_order.update_attributes(address_id: address.id)
    end

    @courier = @lottery_order.couriers.first
    if @courier
      @courier.update_attributes(courier_params)
    else
      @lottery_order.couriers.create(courier_params)
    end

    redirect_to "/admins/lottery_orders/#{@lottery_order.id}"
  end


  def search
    @lottery_orders = LotteryOrder.find_lottery_orders params
    render template: 'admins/lottery_orders/index'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_lottery_order
    @lottery_order = LotteryOrder.includes(:user).find(params[:id])
  end

  def set_product_menu_active
    @menu_active = '中奖订单'
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def lottery_order_params
    params.permit(:lottery_id, :user_id, :request_ip, :total_count, :total_price, :is_win, :status, :address_id)
  end


end
