class Admins::LotteriesController < Admins::ApplicationController
  before_action :set_lottery, only: [:show, :edit, :update, :destroy,:auto_published,:update_lottery,:auto_extension_lottery]
  before_action :set_product_menu_active
  before_action :product_side_menus

  def index
    #商城夺宝列表管理
    @lotteries = Lottery.includes(:product).where('products.product_type': 1)
                     .order(sort: :desc,published_at: :desc)
                     .paginate(:page => params[:page], :per_page => 30)
  end

  def show
    #购买记录
    @lottery = Lottery.includes(:product, :lottery_orders).find(params[:id])
  end

  def new
    @lottery = Lottery.new
  end

  # GET /lotteries/1/edit
  def edit
  end


  def update_lottery
    @lottery.update_attributes(lottery_params)
    redirect_to '/admins/lotteries'
  end

  #自动延期
  def auto_extension_lottery
    if params[:auto_extension_status].to_i == 2
      lo = Lottery.where(product_id: @lottery.product_id,auto_extension_status: 2)
      if lo.present?
        redirect_to '/admins/lotteries',notice: '自动延期失败！同一商品不能重复发布延期！' and return
      end
    end
    @lottery.update_attributes(auto_extension_params)
    redirect_to '/admins/lotteries',notice: '修改成功！'
  end

  def create
    flag = '保存失败！'
    product = Product.find(params[:product_id])
    if (params[:total_count].to_i * params[:price].to_i * SYSTEMCONFIG[:admin_config][:diamond_exchange_rate]) <= product.price
      redirect_to '/admins/lotteries', notice: "发布失败！参与人数×参与单价×钻石币汇率>商品价格，才能进行商品抽奖发布" and return
    end
      @lottery = Lottery.new(lottery_params.merge({interval: product.interval.to_i,lottery_percent: product.lottery_percent}))
      if @lottery.save
        flag = '成功新增加了一期夺宝！'
      end
    redirect_to '/admins/lotteries', notice: flag

  end



  #顶置排行
  def set_sort
    @lottery = Lottery.find(params[:id])
    #sort = Lottery.maximum(:sort)
    @lottery.update_attributes(sort: params[:sort].to_i)
    redirect_to '/admins/lotteries'
  end


  def destroy
    @lottery.destroy
    respond_to do |format|
      format.html { redirect_to lotteries_url, notice: 'Lottery was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def search
    lottery_params = params
    lottery_params = lottery_params.merge({product_type: 1})
    @lotteries = Lottery.find_lottery lottery_params
    render template: 'admins/lotteries/index'
  end



  private

  def set_lottery
    @lottery = Lottery.includes(:product).find(params[:id])
  end

  def set_product_menu_active
    @menu_active = '夺宝列表'
  end

  def lottery_params
    params.permit(:product_id, :published_at, :product_name, :sales_count, :total_count, :price,
                  :status, :lottery_time, :share_code,:interval,:lottery_percent)
  end

  def auto_extension_params
    params.permit(:product_id, :published_at, :product_name, :sales_count, :total_count, :price,
                  :status, :lottery_time, :share_code,:interval,:lottery_percent,
                  :auto_extension_interval,:auto_extension_status,:auto_extension_start_time,:auto_extension_end_time)
  end
end
