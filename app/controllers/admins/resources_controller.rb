class Admins::ResourcesController < Admins::ApplicationController
  before_action :user_side_menus
  before_action :set_product_menu_active
  before_action :set_resources,only: [:edit,:resource_update,:resource_delete]
  def index
    @resources = Resource.paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @all_models = Resource.controller_transfer_model
    @all_controllers = Resource.get_all_controllers
    if params['resource_type'] == 'h5'
      @models = @all_models[:h5_model_arr]
      @all_controllers = @all_controllers[:h5]
    end
    if params['resource_type'] == 'admin'
      @models = @all_models[:admin_modle_arr]
      @all_controllers = @all_controllers[:admin]
    end

    @resource_type = params['resource_type']
  end

  def get_all_controllers
    @all_models = Resource.controller_transfer_model
    @controller_hash = @all_models[:controller_hash]
    render json: @controller_hash
  end

  def get_all_actions
    @all_actions = Resource.get_all_actions
    render json: @all_actions
  end

  def create
    Resource.create(resources_params)
    redirect_to '/admins/resources',notice: '添加成功'
  end

  def edit

  end

  def resource_update
    @resource.update_attributes(resources_params)
    redirect_to '/admins/resources',notice: '修改成功'
  end

  def resource_delete
    @resource.destroy
    redirect_to '/admins/resources',notice: '删除成功'
  end
  private

  def set_resources
    @resource = Resource.find(params[:id])
  end
  def resources_params
    params.permit(:name, :status, :model_n, :controller_n, :action_n, :desc,:resource_type)
  end

  def set_product_menu_active
    @menu_active = '资源权限管理'
  end
end