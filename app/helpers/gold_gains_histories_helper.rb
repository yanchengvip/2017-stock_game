module GoldGainsHistoriesHelper
  # 取倒计时剩余时间
  def get_left_time_by(type)
    case type
    when 'D'
      time_left = ("#{Date.today} 17:30:00".to_time - Time.now).to_i
    when 'W'
      time_left = ("#{Date.today.end_of_week - 1} 17:30:00".to_time - Time.now).to_i
    when "M"
      time_left = ("#{Date.today.end_of_month} 17:30:00".to_time - Time.now).to_i
    when 'T'
      time_left = 1
    when 'TD' # 今天
      time_left = ("#{Date.today} 17:30:00".to_time - Time.now).to_i
    end
    return time_left
  end

  def show_which(type)
    res = {day: '', week: '', month: '', total: ''}
    
    res[:day] = 'unique' if type.include?('日')
    res[:week] = 'unique' if type.include?('周')
    res[:month] = 'unique' if type.include?('月')
    res[:total] = 'unique' if type.include?('总')

    return res
  end

  # 奖励名称
  def rank_item_name(item)
    str = ''
    case item&.prize_type
    when 2
      str = '虚拟资金'
    when 3
      str = '钻石币'
    when 4
      str = "夺宝商品#{item.table.name}"
    when 5
      str = '福袋'
    end
    return str
  end

  def rank(num)
    str = num > 10 ? '' :  num
    str = '' if num.blank? || num == 0
    return str
  end

  def update_rule_txt(type)
    res = ''
    res = '日排行，每天17:30更新排行榜，每天17:30发放奖励' if type.include?('日')
    res = '周排行，每天17:30更新排行榜，每周六17:30发放奖励' if type.include?('周')
    res = '月排行，每天17:30更新排行榜，每月末17:30发放奖励' if type.include?('月')
    res = '总排行，每天17:30更新排行榜' if type.include?('总')

    return res
  end

  def show_or_hide_prise(type)
    
  end

  # 奖励类型
  def prize_type(ranking_config)
    res = {}
    item = ranking_config.ranking_config_items.first
    if item.blank?
      res = {'txt': '无奖励', 'is_product': '0'}
      return res
    end

    case item.prize_type
    when 1
      res = {'txt': '无奖励', 'is_product': 0}
    when 2
      res = {'txt': "获得<span class='-gfc-red'>#{item.price}</span>虚拟资金", 'is_product': 0}
    when 3
      res = {'txt': "获得<span class='-gfc-red'>#{item.price}</span>钻石币", 'is_product': 0}
    when 4
      product = item.table
      res = {'txt': "获得（#{product.name}）", 'is_product': 1}
    when 5
      res = {'txt': "获得价值<span class='-gfc-red'>#{item.price}</span>的神秘福袋", 'is_product': 0}
    when 6
      res = {'txt': "获得钻石礼包", 'is_product': 0}
    when 7
      res = {'txt': "获得现金", 'is_product': 0}
    end

    return res
  end

end
