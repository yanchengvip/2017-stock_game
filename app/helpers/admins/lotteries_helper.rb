module Admins::LotteriesHelper

  #抽奖状态
  def lottery_status status

    case status.to_i
      when -1
        flag = '取消'
      when 0
        flag = '初始'
      when 1
        flag = '待开奖'
      when 2
        flag = '已开奖'

    end

    return flag

  end

  #抽奖订单状态  -1:已作废 0:未发货,1:已发货,2:已兑换收益,3:待发货
  def lottery_order_status status
    case status.to_i
      when -1
        flag = '已作废'
      when 0
        flag = '未发货'
      when 1
        flag = '已发货'
      when 2
        flag = '已兑换收益'
      when 3
        flag = '待发货'

    end

    return flag
  end

  def arry_to_str arry

    if arry.empty?
      return '无'
    end

    return arry.join('、')

  end

  def set_select_option o1, o2
    if o1.to_i == o2.to_i
      return 'selected'
    else
      return ''
    end

  end
end