class Admins::CoinBagsController < Admins::ApplicationController
  before_action :set_coin_bag, only: [:coins_to_user, :coins_to_user_save, :destroy_coin, :search_unselected_users]
  before_action :coin_bag_menus
  before_action :set_coin_bag_menu_active

  def index
    @coin_bags = CoinBag.order(created_at: :desc).paginate(:page => params[:page], :per_page => 20)
  end

  def new

  end

  def create
    if params[:coin_count].to_i > params[:person_count].to_i
      CoinBag.create(coin_bag_params)
      message = '成功新建一个钻石礼包'
    else
      message = '添加失败，钻石币数量不能小于人数'
    end

    redirect_to '/admins/coin_bags', notice: message
  end

  #分发钻石礼包给用户
  def coins_to_user
    @all_users = User.paginate(page: params[:page], per_page: 20)
    respond_to do |format|
      format.html
      format.js
    end

  end

  def coins_to_user_save
    lo_arr = []
    params[:lottery_arr].each do |lottery|
      #根据lottery_num生成多个lottery

      lottery[:lottery_num].to_i.times { |i|
        lo = {user_id: lottery[:user_id], coin_count: @coin_bag.coin_count,
              person_count: @coin_bag.person_count, remain_coin_count: @coin_bag.coin_count,
              end_time: Time.now + (@coin_bag.end_day.to_i).days}
        lo_arr.push(lo)
      }
      @coin_bag.coin_bag_lotteries.create(lo_arr)
      lo_arr = []
    end
    render json: {status: '1', message: '分配成功'}

  end

  def destroy_coin
    @coin_bag.destroy

    redirect_to :back
  end

  def search
    @coin_bags = CoinBag.find_coin_bags params
    render template: 'admins/coin_bags/index'
  end

  def search_unselected_users
    @all_users = User.admin_find_users params
    respond_to do |format|
      format.html { render partial: 'admins/shares/unselected_users' }
      format.js { render 'admins/coin_bags/coins_to_user.js.erb' }
    end

  end

  private

  def set_coin_bag
    @coin_bag = CoinBag.find(params[:id])
    @product = @coin_bag
  end

  def set_coin_bag_menu_active
    @menu_active = '钻石包列表'
  end

  def coin_bag_params
    params.permit(:coin_count, :person_count, :end_time, :is_published,:end_day)
  end
end
