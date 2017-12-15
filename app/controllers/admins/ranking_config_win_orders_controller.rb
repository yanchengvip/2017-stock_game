class Admins::RankingConfigWinOrdersController < Admins::ApplicationController
  before_action :set_ranking_config_win_order, only: :manage
  before_action :ranking_side_menus

  #领取排名的订单管理
  def show
    @rcw_order = RankingConfigWinOrder.includes(:ranking_config_win, :ranking_config, :user, :ranking_config_item, :product,:address).find(params[:id])
    @user_address = @rcw_order.address
    @order_courier = @rcw_order.couriers.first
  end


  #领取排名的订单管理
  def manage


    @ranking_config_win_order.update_attributes(status: params[:status])
    courier_params = {courier_name: params[:courier_name], courier_no: params[:courier_no]}
    @courier = @ranking_config_win_order.couriers.first

    if params[:is_add_address].to_i == 1
      #如果用户没有地址，联系用户保存新地址
      address = @ranking_config_win_order.user.addresses.create(user_name: params[:user_name], phone: params[:user_phone],
                                                      postcode: params[:postcode], address: params[:address])
      @ranking_config_win_order.update_attributes(address_id: address.id)
    end

    if @courier
      @courier.update_attributes(courier_params)
    else
      @ranking_config_win_order.couriers.create(courier_params)
    end

    redirect_to :back
  end


  private

  def set_ranking_config_win_order
    @ranking_config_win_order = RankingConfigWinOrder.includes(:user).find(params[:id])
  end


  def ranking_config_win_order_params
    params.require(:ranking_config_win_order).permit(:ranking_config_id, :ranking_config_item_id, :user_id, :status, :product_id, :total_count, :total_price, :address_id, :request_ip)
  end
end
