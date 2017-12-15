class H5::LotteryOrdersController < ApplicationController
  before_action :set_lottery_order, only: [:show,:update_status, :take_award]
  skip_before_action :verify_signature
  skip_before_filter :verify_authenticity_token

  def self_lottery_orders
    @q = LotteryOrder.includes(:lottery_order_items).where("user_id > 0").ransack(params[:q])
    @lottery_orders = @q.result.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: {status: 200, data: @lottery_orders, msg: "success"}}
    end
  end

  def index

    @q = LotteryOrder.includes(:user).where("user_id > 0").ransack(params[:q])
    @lottery_orders = @q.result.page(params[:page])
    respond_to do |format|
      format.html
      format.json {render json: {status: 200, data: @lottery_orders, msg: "success"}}
    end
  end

  def create
    if params[:lottery_id].blank?
      render json: {status: 500, msg: "夺宝编号不能为空", data: {}}
    # elsif params[:total_count].to_i < 1
      # render json: {status: 500, msg: "本期每人最多参与#{}次<br>您还可以参与#{}次"}
    else
      lottery = Lottery.where(id: params[:lottery_id], product_type: 1 ).first
      if lottery
        render json: lottery.lottery_order_create(current_user, params[:total_count].to_i, request.ip)
      else
        render json: {status: 500, msg: "夺宝活动不存在", data: {}}
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lottery_order
      @lottery_order = LotteryOrder.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def lottery_order_params
      params.permit(:lottery_id, :user_id, :request_ip, :total_count, :total_price, :is_win, :status, :address_id)
    end


end
