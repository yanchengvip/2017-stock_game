class Admins::MicroDiamondBagsController < Admins::ApplicationController
  before_action :micro_diamond_bag_menus
  before_action :set_micro_diamond_bag, only: [:edit, :update_micro, :destroy_micro,:show]


  def index
    @menu_active = '红包列表'
    @micro_bags = MicroDiamondBag.paginate(:page => params[:page], :per_page => 30)
  end

  def show
    @menu_active = '已完成红包'
  end

  def new
    @menu_active = '红包列表'
  end

  def edit
    @menu_active = '红包列表'
  end

  def update_micro
    @menu_active = '红包列表'
    @micro_bag.update_attributes(micro_diamond_bag_params)
    redirect_to '/admins/micro_diamond_bags', notice: '修改成功'
  end

  def create
    @menu_active = '红包列表'
    MicroDiamondBag.create(micro_diamond_bag_params)
    redirect_to '/admins/micro_diamond_bags', notice: '保存成功'
  end

  def destroy_micro
    @menu_active = '红包列表'
    @micro_bag.destroy
    redirect_to '/admins/micro_diamond_bags', notice: '删除成功'
  end


  def finish_list
    @menu_active = '已完成红包'
    @micro_bags = MicroDiamondBag.includes(:micro_diamond_bag_items).where(status: [1,2]).paginate(:page => params[:page], :per_page => 30)
  end

  def micro_setting
    @menu_active = '红包设置'
  end

  private

  def set_micro_diamond_bag
    @micro_bag = MicroDiamondBag.includes(:micro_diamond_bag_items).find(params[:id])
  end

  def micro_diamond_bag_params
    params.permit(:micro_diamond_amount, :person_count, :buy_diamond_amount, :published_at,
                  :buy_at, :is_active, :user_id, :total_count, :end_time, :award)
  end


end
