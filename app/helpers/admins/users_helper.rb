module Admins::UsersHelper

  def user_roles_name  role
    case role.to_i
      when 1
        f = '普通用户'
      when 2
        f = '管理员'
      when 3
        f = '内测用户'
    end
    return f
  end


  def nickname_and_phone user
    name = user.nickname.present? ? user.nickname : '姓名为空'
    phone = user.phone.present? ?  user.phone : '手机为空'
    return name + '--' + phone
  end

  def nickname_or_phone user

    if user.nickname.present?
       return user.nickname
    end
    if user.phone.present?
      return user.phone
    end

  end

  def user_nickname user
    name = user.nickname.present? ? user.nickname : '姓名为空'

  end

  def user_phone user
    phone = user.phone.present? ?  user.phone : '手机为空'
  end

  def admin_resource_status status
      case status.to_i
        when 0
          f = '禁用'
        when 1
          f = '启用'
      end

      return f
  end

end
