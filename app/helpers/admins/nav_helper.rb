module Admins::NavHelper
  def nav_active1
    flag = ''
    if params[:controller] == 'admins/homes'
      flag = 'active'
    end
    return flag
  end

  def nav_active2
    flag = ''
    if params[:controller] == 'admins/ranking_config_wins' || params[:controller] == 'admins/ranking_configs'
      flag = 'active'
    end
    return flag
  end

  def nav_active3
    flag = ''
    if params[:controller] == 'admins/products' || params[:controller] == 'admins/lotteries' || params[:controller] == 'admins/lottery_orders'
      flag = 'active'
    end

    return flag
  end

  def nav_active4
    flag = ''
    if params[:controller] == 'admins/lucky_bags'
      flag = 'active'
    end
    return flag
  end

  def nav_active5
    flag = ''
    if params[:controller] == 'admins/coin_bags'
      flag = 'active'
    end
    return flag
  end

  def nav_active6
    flag = ''
    if params[:controller] == 'admins/users' || params[:controller] == 'admins/resources'
      flag = 'active'
    end
    return flag
  end

  def nav_active7
    flag = ''
    if params[:controller] == 'admins/download_csv'
      flag = 'active'
    end
    return flag
  end

  def nav_active8
    flag = ''
    if params[:controller] == 'admins/share_configs' || params[:controller] == 'admins/other_manages'
      flag = 'active'
    end
    return flag
  end


  def nav_active9
    flag = ''
    if params[:controller] == 'admins/micro_diamond_bags'
      flag = 'active'
    end
    return flag
  end
end