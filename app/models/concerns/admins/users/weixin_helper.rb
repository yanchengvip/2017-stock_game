module Admins
  module Users
    module WeixinHelper

      module ClassMethods

      end

      module InstanceMethods

        #生成用戶二维码
        def generate_user_qrcode
          Wechat.api.qrcode_create_limit_scene Utils.generate_uuid
        end
      end


    end
  end

end