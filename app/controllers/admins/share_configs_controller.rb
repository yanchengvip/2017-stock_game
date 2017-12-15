class Admins::ShareConfigsController < Admins::ApplicationController
  before_action :set_share_config, only: [:share_delete,:share_update,:edit]
  before_action :other_manage_menus


  def index
    @menu_active = '分享内容管理'
    @share_configs = ShareConfig.paginate(:page => params[:page], :per_page => 20)
  end


  def new
    #@share_configs = ShareConfig.paginate(:page => params[:page], :per_page => 20)
  end

  def edit

  end

  def share_update
    @share_config.update_attributes(share_config_params)
    redirect_to '/admins/share_configs',notice: '修改成功！'
  end

  def share_delete
    @share_config.destroy
    redirect_to '/admins/share_configs',notice: '删除成功！'
  end

  def create
    ShareConfig.create(share_config_params)
    redirect_to '/admins/share_configs'
  end


  private

  def set_share_config
    @share_config = ShareConfig.find(params[:id])
  end


  def share_config_params
    params.permit(:title, :desc, :img_url, :link_url, :user_id,:share_type,:status)
  end
end
