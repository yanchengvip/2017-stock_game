module Admins::ResourcesHelper
    def show_resource_type type
      case type.to_i
        when 0
          f = '无'
        when 1
          f = 'H5权限资源'
        when 2
          f = '后台权限资源'
      end
      return f
    end
end