class WechatSubscribeJob < ApplicationJob
  queue_as :wechat_subscribe
  # wechat_api

  def perform
    wechat = Wechat::Api.new(WECHATCONFiG[:appid], WECHATCONFiG[:secret], nil, 30, nil, nil)
    subscribed_user_openids = wechat.users['data']['openid']

    users = User.where("openid is not null and subscribe_status = ?", 0).where(openid: subscribed_user_openids)
      begin
        users.update_all(subscribe_status: 1)
      rescue Exception => e
        Rails.logger.info('修改用户关注状态失败' + e.to_s)
      end
  end

end