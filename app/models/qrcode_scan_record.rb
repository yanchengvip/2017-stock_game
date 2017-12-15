class QrcodeScanRecord < ApplicationRecord
  validates :openid, uniqueness: true
  belongs_to :qrcode

  #扫码关注
  def self.scan_record_save params
    UserSignLog.subscribe_log params
    begin
      if params[:EventKey].present? && params[:EventKey].start_with?("qrscene")
        #公众号收到未关注用户扫描qrscene_xxxxxx带参数的场景二维码时
        scene_id = params[:EventKey].split("_").last
        openid = params[:FromUserName]
        qrcode = Qrcode.where(scene_id: scene_id).first
        if qrcode
          qrcode.qrcode_scan_records.create(openid: openid, scene_id: scene_id)
        end
      end
    rescue Exception => e
      Rails.logger.info(e)
    end

  end
end