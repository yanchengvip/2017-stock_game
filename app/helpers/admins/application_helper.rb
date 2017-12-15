module Admins::ApplicationHelper


  def time_format date_time
      if date_time.present?
        date_time = date_time.strftime('%Y-%m-%d %H:%M')
      else
        date_time = ''
      end
      return date_time
  end

  def date_format date_time
    if date_time.present?
      date = date_time.strftime('%Y-%m-%d')
    else
      date = ''
    end
    return date
  end

  def menu_active1
    if ['商品列表','福袋列表','管理员管理','钻石包列表','收益领奖记录','下载记录','分享内容管理','红包列表'].include? @menu_active
      flag = 'active'
    end
    return flag
  end

  def menu_active2
    if ['夺宝列表','福袋抽奖列表','收益率领奖记录','用户管理','宝箱管理','用户基本情况统计','已完成红包'].include? @menu_active
      flag = 'active'
    end
    return flag
  end

  def menu_active3

    if ['中奖订单','福袋中奖纪录','收益奖品设置','二维码管理','赔率相关设置','渠道统计','红包设置'].include? @menu_active
      flag = 'active'
    end
    return flag
  end

  def menu_active4

    if ['商城设置','福袋设置','收益率奖品设置','商品标签','资源权限管理'].include? @menu_active
      flag = 'active'
    end
    return flag
  end

  def menu_active5

    if ['竞赛分享设置'].include? @menu_active
      flag = 'active'

    end
    return flag
  end


  def menu_active6

    if ['中奖订单统计'].include? @menu_active
      flag = 'active'

    end
    return flag
  end


  def menu_active7

    if ['资金余额统计'].include? @menu_active
      flag = 'active'

    end
    return flag
  end

  def menu_active8

    if ['资金变动统计'].include? @menu_active
      flag = 'active'

    end
    return flag
  end
  def menu_active9

    if ['资金月报统计'].include? @menu_active
      flag = 'active'

    end
    return flag
  end




  # 夺宝记录页面的时间格式
  def time_str date_time
    str = ''
    str = date_time.strftime('%Y.%m.%d %H:%M:%S') if date_time.present?

    return str
  end

end
