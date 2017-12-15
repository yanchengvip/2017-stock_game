module UsersHelper

  def phone_str(phone)
    phone.present? ? phone.gsub(/(\d{3})\d{4}(\d{4})/) { "#{$1}****#{$2}" } : '未绑定手机号'
  end

  def h5_show_pay_status status
    case status.to_i
      when 0
        t = '未支付'
      when 1
        t = '支付成功'
      when 2
        t = '支付失败'
      when 3
        t = '交易关闭'

    end
    return t
  end


  def h5_show_pay_type pay_type
    case pay_type.to_i
      when 0
        s = '微信'
      when 1
        s = '支付宝'
      when 2
        s = '微信'
      when 3
        s = '微信'
    end

    return s

  end
end
