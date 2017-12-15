module Admins::MicroDiamondBagsHelper


  def admin_micro_diamond_bags_status status
      case status.to_i
        when 0
          f = '未开始'
        when 1
          f = '进行中'
        when 2
          f = '已结束'
      end

      return f
  end

  def admin_micro_diamond_active active
    case active
      when false
        f = '未启用'
      when true
        f = '已启用'
    end

    return f
  end
end
