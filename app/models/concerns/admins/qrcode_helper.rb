module Admins
  module QrcodeHelper
    extend ActiveSupport::Concern

    module ClassMethods

      # 渠道注册、各次分裂数据
      def channel_datas qrcodes
        res = []
        qrcodes.each do |qrcode|
          qrcode_qrsrs = QrcodeScanRecord.select("qrcode_id, openid").where(qrcode_id: qrcode.id)
          first_user_ids = User.where(openid: qrcode_qrsrs.map(&:openid)).map(&:id)
          second_userids = User.where(share_user_id: first_user_ids).pluck(:id)
          second_count = second_userids.size
          third_count = User.where(share_user_id: second_userids).count

          res << {"#{qrcode.user_name}": {reg_count: qrcode_qrsrs.size, second_count: second_count, third_count: third_count}}
        end

        return res
      end

      # 渠道明细
      def channel_details qrcode, occur_date, page
        res = []
        conditions = ["qrcode_id = ?"]
        values = [qrcode.id]
        if occur_date.present?
          conditions << "created_at >= ? and created_at <= ?"
          values << occur_date.to_date.beginning_of_day << occur_date.to_date.end_of_day
        end
        # qrcode_qrsrs = QrcodeScanRecord.select("id, qrcode_id, openid, created_at").where("qrcode_id = ? and created_at >= ? and created_at <= ?", qrcode.id, occur_date.to_date.beginning_of_day, occur_date.to_date.end_of_day)
        qrcode_qrsrs = QrcodeScanRecord.select("id, qrcode_id, openid, created_at")
                                       .where(conditions.join(' and '), *values)
                                       # .paginate(page: page, per_page: 10)

        first_user_ids = User.where(openid: qrcode_qrsrs.map(&:openid)).map(&:id)
        second_userids = User.where(share_user_id: first_user_ids).pluck(:id)
        second_count = second_userids.size
        third_count = User.where(share_user_id: second_userids).count

        res << {"#{qrcode.user_name}": {reg_count: qrcode_qrsrs.size, second_count: second_count, third_count: third_count}}

        return res
      end

      def channel_details_group qrcode, page
        res = []
        qrcode_qrsrs = QrcodeScanRecord.select("id, qrcode_id, openid, created_at")
                                       .where(qrcode_id: qrcode.id)
                                       # .paginate(page: page, per_page: 10)

        qrcode_qrsrs.group_by{|x| x.created_at.to_date}.each do |qrsc|
          first_user_ids = User.where(openid: qrsc[1].map(&:openid)).map(&:id)
          second_userids = User.where(share_user_id: first_user_ids).pluck(:id)
          second_count = second_userids.size
          third_count = User.where(share_user_id: second_userids).count
          res << {"#{qrcode.user_name}": {occur_data: qrsc[0], reg_count: qrsc[1].size, second_count: second_count, third_count: third_count}}
        end
        # QrcodeScanRecord.select("id, qrcode_id, count(openid) as amount, DATE_FORMAT(created_at,'%Y.%m.%d') as days").where(qrcode_id: qrcode.id).group("DATE_FORMAT(created_at,'%Y.%m.%d')").paginate(page: page, per_page: 10)

        return res
      end
    end
  end
end






