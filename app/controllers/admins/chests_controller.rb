class Admins::ChestsController < Admins::ApplicationController
  before_action :other_manage_menus
  before_action :set_chest, only: [:edit, :update, :disable]
  # before_action :ranking_side_menus
  # before_action :set_earning_manage_menu_active, only: [:earning_manage]
  # before_action :set_rate_manage_menu_active, only: [:rate_manage]

  def index
    @menu_active = '宝箱管理'
    @chests = Chest.where(status: 1).order(:odds).paginate(:page => params[:page], :per_page => 30)
  end

  def new
    @chest = Chest.new
  end

  def edit
    @menu_active = '宝箱管理'
  end

  def update
    old_chest = Chest.where("odds = ? and status = ?", params[:chest][:odds], 1).first
    begin
      ActiveRecord::Base.transaction do
        old_chest.update_attributes!(status: 0) if old_chest
        Chest.create!(chest_params)
        redirect_to '/admins/chests/', notice: '修改成功'
      end
    rescue Exception => e
      redirect_to '/admins/chests/', notice: '修改失败'
    end
  end

  def create
    old_chest = Chest.where("odds = ? and status = ?", params[:chest][:odds], 1).first
    @chest = Chest.new(chest_params)
    begin
      ActiveRecord::Base.transaction do
        if @chest.save && old_chest.present?
          old_chest.update_attributes(status: 0)
        end
      end
      redirect_to '/admins/chests/', notice: '添加成功'
    rescue Exception => e
      Rails.logger.info('添加宝箱赔付失败' + e.to_s)
      redirect_to '/admins/chests/', notice: '添加失败'
    end
  end

  # 禁用
  def disable
    if @chest.update_attributes(status: 0)
      return render json: {status: 200, msg: '操作成功'}
    end
    return render json: {status: 500, msg: '操作失败，清重试'}
  end

  private

  def chest_params
    params.require(:chest).permit(:odds, :total_count, :status)
  end

  def set_chest
    @chest = Chest.find(params[:id])
  end
end
