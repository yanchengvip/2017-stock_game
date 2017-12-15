module LotteriesHelper
  # 取倒计时剩余时间
  def lottery_status_str(lottery)
    res = {}
    case lottery.status
    when 0,1
      res = { val: 1, str: '商品待揭晓...', user_id: nil }
    # when 1
    #   res = { val: 1, str: '待揭晓，结果正在计算中...', user_id: nil }
    when 2
      win_user = lottery.win_user
      name = win_user&.nickname || win_user&.phone
      res = { val: 2, str: "获奖者：#{filter_string(name)}", user_id: win_user&.id}
    end
    return res
  end

  # 中奖订单的状态
  def order_status_str(order)
    res = {}
    case order.status
    when 0
      res = {str: '奖品未发货'}
    when 1
      # 已发货 顺丰107998935964
      courier = order.couriers.first
      res = {str: "已发货 #{courier&.courier_name}#{courier&.courier_no}"}
    when 2
      # 已兑换收益￥9,625.00
      lottery = order.lottery
      # number_to_currency
      res = {str: "已兑换收益#{(lottery&.price * lottery&.total_count * (1 - SYSTEMCONFIG[:lottery_system_persent].to_f)).to_i}"}
    when 3
      res = {str: '奖品待发货'}
    end
    return res
  end

  def code_show(items)
    text = ""
    items.each_with_index do |item, index|
      if item.is_win
        text << "<i class='colorPurple'>#{item.lottery_code}</i>"
      else
        text << item.lottery_code
      end
      index == (items.size - 1) ? '' : (text << '、')
    end
    return text
  end

  def win_time_show new_ten_order
    minutes = ((Time.now - new_ten_order.lottery_time) / 60).to_f
    if minutes / 60 >= 24
      return ((minutes / 60) / 24).to_i.to_s + '天'
    elsif minutes >= 60
      return (minutes / 60).to_i.to_s + '小时'
    elsif minutes >= 1
      return minutes.to_i.to_s + '分钟'
    else
      return (minutes * 60).to_i.to_s + '秒'
    end
  end

end
