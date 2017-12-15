class Admins::LotteryOrderItemsController < Admins::ApplicationController
  before_action :set_lottery_order_item, only: [:show, :edit, :update, :destroy]


  def index
    @lottery_order_items = LotteryOrderItem.all
  end


  def show
  end


  def new
    @lottery_order_item = LotteryOrderItem.new
  end


  def edit
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_lottery_order_item
    @lottery_order_item = LotteryOrderItem.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def lottery_order_item_params
    params.require(:lottery_order_item).permit(:lottery_id, :lottery_order_id, :user_id, :lottery_code, :request_ip, :is_win)
  end
end
