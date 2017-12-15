module Admins::ShareConfigsHelper

  def admin_share_config_type share_type
      case share_type.to_i
        when 0
          s = '无'
        when 1
          s = '微信内容分享'
        when 2
          s = '公告管理'
      end

    return s
  end

  def admin_share_config_status status
    case status.to_i
      when 0
        s = '禁用'
      when 1
        s = '启用'

    end
    return s
  end

  def type_is_selected_option share_config,type
      if share_config.share_type.to_i == type.to_i
         return 'selected'
      end
  end

  def status_is_selected_option share_config,status
    if share_config.status.to_i == status.to_i
      return 'checked'
    end
  end

  def admin_resource_type_is_selected resource_type,status
    if resource_type.to_i == status.to_i
      return 'selected'
    end
  end
end