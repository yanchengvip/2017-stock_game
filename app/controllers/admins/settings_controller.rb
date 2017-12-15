class Admins::SettingsController < Admins::ApplicationController
  before_action :other_manage_menus


  def index
    @menu_active = '赔率相关设置'
    @settings = Setting.get_all
  end

  def update_sets
    params[:settings].each_key do |key|
      Setting.send("#{key}=", params[:settings][key])
    end if params[:settings].present?
    clear_cache_datas
    # redirect_to action: :index, notice: '修改成功'
    redirect_to '/admins/settings/', notice: '修改成功'
  end

  def clear_cache_datas
    $cache.set("bet_max_coin_now", nil)
    $cache.set("day_coin_pool", nil)
    $cache.set("day_chance", nil)
    $cache.set("chest_odds_container_now", nil)
    # $cache.set("free_coin_now", nil)
    # $cache.set("fresh_odd_max", nil)
    # $cache.set("fresh_odd_min", nil)
    day = Date.today
    # $cache.set("free_times_day#{day}", nil)
    $cache.set("free_share_times_day#{day}", nil)
  end
end
