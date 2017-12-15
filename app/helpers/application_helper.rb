module ApplicationHelper
  def filter_string(str)
    if str.size > 4
      str.first(2)+"*"+str.last(2)
    elsif str.size > 2
      str.first(2)+"*"
    else
      str[0] + "****"
    end
  end

  #开奖时间
  def lottery_time
    open_times = []
    day_begin = Date.today.to_time
    (1..23).each do |i|
      open_times << day_begin + i * 5 * 60 + 60
    end
    (60..132).each do |i|
      open_times << day_begin + i * 10 * 60 + 60
    end
    (265..288).each do |i|
      open_times << day_begin + i * 5 * 60 + 60
    end
    open_times.each do |x|
      if x > Time.now
        return x.strftime("%Y/%m/%d %H:%M:%S")
      end
    end
  end

  #为 number_to_currency 增加默认值
  def number_to_currency number, options = {}
    options[:unit] = "" if options[:unit].blank?
    ActiveSupport::NumberHelper.number_to_currency(number, options)
  end

  def booking_trade_status status
    case status
    when 0
      "已报"
    when 1
      "成交"
    when -1
      "已撤"
    end
  end
  def booking_trade_bussiness_type bussiness_type
    case bussiness_type
    when 1
      "买入"
    when 2
      "卖出"
    when 3
      "做空"
    when 4
      "平仓"
    end
  end

  def to_zw(num)
    num_zw = {1 => '一', 2 => '二', 3 => '三', 4 => '四', 5 => '五', 6 => '六', 7 => '七', 8 => '八', 9 => '九', 10 => '十'}
    return num_zw[num]
  end
end
