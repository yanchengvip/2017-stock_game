#记录每天关微信注和取消的用户，仅保存一条记录
#用户状态user_status; 0:无,1:微信关注,2:取消关注,3:h5注册
class UserSignLog < ApplicationRecord
  validates_uniqueness_of :openid, scope: [:user_status, :record_date], allow_nil: true


#微信关注日志
  def self.subscribe_log params
    begin
      #记录用户关注日志
      UserSignLog.create(openid: params[:FromUserName], record_date: Time.now, user_status: 1)
    rescue Exception => e
      Rails.logger.info(e)
    end
  end

#微信取消关注日志
  def self.unsubscribe_log params
    begin
      #记录用户关注日志
      UserSignLog.create(openid: params[:FromUserName], record_date: Time.now, user_status: 2)
    rescue Exception => e
      Rails.logger.info(e)
    end
  end
end