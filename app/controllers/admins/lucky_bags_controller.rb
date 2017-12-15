#分享福袋
class Admins::LuckyBagsController < Admins::ApplicationController
  before_action :set_product, only: [:bags_to_user, :destroy_bag, :bag_selected_user,:search_unselected_users]
  before_action :lucky_bag_side_menus

  def index
    @menu_active = '福袋列表'
    @lucky_bags = Product.includes(:lotteries,:ranking_config_items).where('product_type': 2)
                      .order(created_at: :desc)
                      .paginate(:page => params[:page], :per_page => 30)
  end

  def new
    @menu_active = '福袋列表'
  end

  def create
    @product = Product.new(product_params.merge({product_type: 2}))
    @product.save
    redirect_to '/admins/lucky_bags'
  end

  #分发福袋
  def bags_to_user
    @menu_active = '福袋列表'
    @all_users = User.includes(:lottery_orders).paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.js
    end

  end


  def bag_selected_user

    lo_arr = []
    #验证当前用户数量和该钻石包剩余数量是否匹配
    selected_num = 0 #选中的分配数量
    params[:lottery_arr].each do |lottery|
      selected_num += lottery[:lottery_num].to_i
    end
    inventory_count = @product.inventory_count
    if selected_num > inventory_count
      render json: {status: '2', message: '选择的数量大于当前库存，请重新选择'} and return
    end
    params[:lottery_arr].each do |lottery|
      #根据lottery_num生成多个lottery

      lottery[:lottery_num].to_i.times { |i|
        lo = {user_id: lottery[:user_id], total_count: @product.total_count,
              product_name: @product.name, award: @product.award,
              end_time: @product.end_time, published_at: Time.new}
        lo_arr.push(lo)
      }
      @product.inventory_count -= selected_num
      if @product.save
        @product.lotteries.create(lo_arr)
      end

      lo_arr = []
    end
    render json: {status: '1', message: '分配成功'}
  end


  def destroy_bag
    @product.destroy()
    redirect_to '/admins/lucky_bags'
  end

  #福袋抽奖列表
  def lottery_list
    @menu_active = '福袋抽奖列表'
    @lotteries = Lottery.includes(:product, :user)
                     .order(created_at: :desc)
                     .where('products.product_type': 2)
                     .paginate(:page => params[:page], :per_page => 20)
  end

  #单个福包的抽奖记录详情
  def lottery_details
    @menu_active = '福袋抽奖列表'
    @lottery = Lottery.includes(:lottery_order_items, :product, :user).find(params[:lottery_id])
    #需要总参与人数
    @lottery_count = @lottery.total_count.to_i

    #已参与人次
    @loi_count = @lottery.sales_count

    #抽奖的记录
    @lottery_order_items = @lottery.lottery_order_items.includes(:user)

  end

  #福袋中奖的全部记录
  def win_items
    @menu_active = '福袋中奖纪录'
    @lottery_order_items = LotteryOrderItem.includes(:user, :product, :lottery, :lottery_order)
                               .order(created_at: :desc)
                               .where(is_win: true, 'products.product_type': 2)
                               .paginate(:page => params[:page], :per_page => 20)
    #@lottery_wind_orders = LotteryOrder.includes(:user,:product,:lottery).where(is_win: true,'products.product_type': 2)
    #   .paginate(:page=>params[:page],:per_page=>20)
  end

  #管理福袋抽奖订单
  def manage_order
    @menu_active = '福袋中奖纪录'
    @lottery_order_item = LotteryOrderItem.includes(:user, :product, :lottery, :lottery_order)
                              .find(params[:item_id])
    @lottery_order = @lottery_order_item.lottery_order
    @user_address = @lottery_order_item.lottery_order.address
    @order_courier = @lottery_order.couriers.first
  end

  def setting
    @menu_active = '福袋设置'
  end

  #福袋列表查询
  def search
    @menu_active = '福袋列表'
    search_params = params
    search_params = search_params.merge({product_type: 2})
    @lucky_bags = Product.find_products search_params
    render template: 'admins/lucky_bags/index'
  end

  #福袋抽奖列表查询
  def search_lottery_list
    @menu_active = '福袋抽奖列表'
    lottery_params = params
    lottery_params = lottery_params.merge({product_type: 2})
    @lotteries = Lottery.find_lottery lottery_params
    render template: 'admins/lucky_bags/lottery_list'

  end

  #福袋中奖记录查询
  def search_win_items
    @menu_active = '福袋中奖纪录'
    win_item_params = params
    win_item_params = win_item_params.merge({product_type: 2})
    @lottery_order_items = LotteryOrderItem.find_lottery_order_items win_item_params

    render template: 'admins/lucky_bags/win_items'
  end


  def search_unselected_users
    #@all_users = User.ransack(nickname_or_phone_cont: params[:name_or_phone]).result#.page(params[:page])
    @all_users = User.admin_find_users params
    respond_to do |format|
      format.html { render partial: 'admins/shares/unselected_users' }
      format.js { render 'admins/lucky_bags/bags_to_user.js.erb' }
    end

  end
  private

  def set_product
    @product = Product.includes(:lottery_orders).find(params[:id])
  end

  def product_params
    params.permit(:name, :desc, :price, :inventory_count, :detail_url, :head_image, :is_published, :user_id, :total_count, :end_time, :award)
  end

end