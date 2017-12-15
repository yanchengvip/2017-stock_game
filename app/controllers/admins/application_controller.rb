class Admins::ApplicationController < ActionController::Base
  layout "admin"
  before_action :authenticate_user
  helper_method :current_user

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { head :forbidden }
      #format.html { redirect_to main_app.root_url, :alert => exception.message }
    end
  end

  # cancan Admin Namespace
  def current_ability
    @current_ability ||= AdminAbility.new(current_user)
  end

  def verify_phone_code?
    $cache.get(params["phone"]) == params["code"] && !params["code"].blank?
  end

  def current_user

    begin
      user ||= Admin.find(session[:admin_id])
      if  user.role.to_i == 2
        @current_user = user
      end
    rescue Exception => e
      nil
    end
  end

  def authenticate_user
    return if current_user
    phone_auth
  end

  def phone_auth
    redirect_to "/admins/login"
  end


  private

  #商城管理 左侧菜单
  def product_side_menus
    @side_menus = 'admin_product_layout'
  end

  def lucky_bag_side_menus
    @side_menus = 'admin_lucky_bag_layout'
  end

  def ranking_side_menus
    @side_menus = 'admin_ranking_layout'
  end

  def user_side_menus
    @side_menus = 'admin_user_layout'
  end

  def coin_bag_menus
    @side_menus = 'admin_coin_bag_layout'
  end

  def csv_menus
    @side_menus = 'admin_csv_layout'
  end

  def other_manage_menus
    @side_menus = 'admin_other_manage_layout'
  end

  def micro_diamond_bag_menus
    @side_menus = 'admin_micro_diamond_bag_layout'
  end
end
