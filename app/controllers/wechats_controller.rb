class WechatsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_action :authenticate_user
  wechat_responder
  wechat_api
  # For details on the DSL available within this file, see https://github.com/Eric-Guo/wechat#rails-responder-controller-dsl
  wechat_responder

  # default text responder when no other match
  # on :text do |request, content|
  #   request.reply.text "echo: #{content}" # Just echo
  # end

  # When receive 'help', will trigger this responder
  on :text, with: '阿花' do |request|
    media_id = $cache.fetch("wechat_ahua_resopnse", 2 * 3600 * 24){
      res = wechat.media_create( "image", "public/default_image/wechat_ahua_resopnse.png")
      res["media_id"]
    }
    request.reply.image(media_id)
  end

  # # When receive '<n>news', will match and will get count as <n> as parameter
  # on :text, with: /^(\d+) news$/ do |request, count|
  #   # Wechat article can only contain max 10 items, large than 10 will be dropped.
  #   news = (1..count.to_i).each_with_object([]) { |n, memo| memo << { title: 'News title', content: "No. #{n} news content" } }
  #   request.reply.news(news) do |article, n, index| # article is return object
  #     article.item title: "#{index} #{n[:title]}", description: n[:content], pic_url: 'http://www.baidu.com/img/bdlogo.gif', url: 'http://www.baidu.com/'
  #   end
  # end

  on :event, with: 'subscribe' do |request|

    QrcodeScanRecord.scan_record_save request
    begin
      ActiveRecord::Base.transaction do
        diamond_type = DiamondAccount::DIAMONDTYPE['关注钻石大富翁公众号奖励']

        if request[:FromUserName] && (user = User.find_by(openid: request[:FromUserName])) && user&.subscribe_status != 1
          if user.subscribe_status == 0
            DiamondAccount.create!(user_id: user.id, amount: SYSTEMCONFIG["admin_config"]["subscribe"]["diamond_account"], diamond_type: diamond_type)
          end
          user.update_attributes!(subscribe_status: 1)

          # 扫描直接创建用户
        elsif request[:FromUserName] && User.find_by(openid: request[:FromUserName]).blank?
          # wechater = Wechat::Api.new(WECHATCONFiG[:appid], WECHATCONFiG[:secret], nil, 30, nil, nil)
          # wx_user = wechater.user request[:FromUserName]
          wx_user = Wechat.api.user request[:FromUserName]
          user = User.create!(wx_user.with_indifferent_access.slice(:province, :openid, :nickname, :sex, :city, :country, :headimgurl, :unionid).merge({total_gold: SYSTEMCONFIG[:admin_config][:user_register][:gold], available_gold: SYSTEMCONFIG[:admin_config][:user_register][:gold]}))


          if user
            DiamondAccount.create!(user_id: user.id, amount: SYSTEMCONFIG["admin_config"]["subscribe"]["diamond_account"], diamond_type: diamond_type)
            user.update_attributes!(subscribe_status: 1)
          end

        end

      end
    rescue Exception => e
      Rails.logger.info(e)
    end

    # request.reply.text "以人民的名义保证，史上最公平公正公开的夺宝活动正在疯狂进行中，iPhone 7、克拉钻、爱马仕免费拿，点击【<a href='#{SYSTEMCONFIG[:host]}'>0元夺宝</a>】试试你的手气吧~"
    request.reply.text "嗨，终于等到你！拯救银河系才能换取你的到来！\r\n☞最劲爆：<a href='#{SYSTEMCONFIG[:host]}'>大奖中到尖叫~~~ </a>\r\n☞回复 “阿花” 获取客服微信，你现在想什么她都知道\r\n赶紧点击下方【<a href='#{SYSTEMCONFIG[:host]}'>0元夺宝</a>】试试手气吧！！！"
  end

  # # When unsubscribe user scan qrcode qrscene_xxxxxx to subscribe in public account
  # # notice user will subscribe public account at the same time, so wechat won't trigger subscribe event anymore
  # on :scan, with: 'qrscene_xxxxxx' do |request, ticket|
  #   request.reply.text "Unsubscribe user #{request[:FromUserName]} Ticket #{ticket}"
  # end

  # # When subscribe user scan scene_id in public account
  # on :scan, with: 'scene_id' do |request, ticket|
  #   request.reply.text "Subscribe user #{request[:FromUserName]} Ticket #{ticket}"
  # end

  # # When no any on :scan responder can match subscribe user scanned scene_id
  # on :event, with: 'scan' do |request|
  #   if request[:EventKey].present?
  #     request.reply.text "event scan got EventKey #{request[:EventKey]} Ticket #{request[:Ticket]}"
  #   end
  # end

  # # When enterprise user press menu BINDING_QR_CODE and success to scan bar code
  # on :scan, with: 'BINDING_QR_CODE' do |request, scan_result, scan_type|
  #   request.reply.text "User #{request[:FromUserName]} ScanResult #{scan_result} ScanType #{scan_type}"
  # end

  # # Except QR code, wechat can also scan CODE_39 bar code in enterprise account
  # on :scan, with: 'BINDING_BARCODE' do |message, scan_result|
  #   if scan_result.start_with? 'CODE_39,'
  #     message.reply.text "User: #{message[:FromUserName]} scan barcode, result is #{scan_result.split(',')[1]}"
  #   end
  # end

  # # When user clicks the menu button
  # on :click, with: 'BOOK_LUNCH' do |request, key|
  #   request.reply.text "User: #{request[:FromUserName]} click #{key}"
  # end

  # When user clicks the menu button
  on :click, with: 'contact_customer_service' do |request, key|
    request.reply.text "您好！ 如有任何疑问或者建议，请在公众号对话框中留言哦～客服人员会尽快回复您。同时，也可通过以下几种方式联系我们~\r\n（1）电话：400 900 5670\r\n（2）微信：zuanliankeji\r\n（3）QQ：4009005670"
  end

  # # When user views URL in the menu button
  # on :view, with: 'http://wechat.somewhere.com/view_url' do |request, view|
  #   request.reply.text "#{request[:FromUserName]} view #{view}"
  # end

  # # When user sends an image
  # on :image do |request|
  #   request.reply.image(request[:MediaId]) # Echo the sent image to user
  # end

  # # When user sends a voice
  # on :voice do |request|
  #   request.reply.voice(request[:MediaId]) # Echo the sent voice to user
  # end

  # # When user sends a video
  # on :video do |request|
  #   nickname = wechat.user(request[:FromUserName])['nickname'] # Call wechat api to get sender nickname
  #   request.reply.video(request[:MediaId], title: 'Echo', description: "Got #{nickname} sent video") # Echo the sent video to user
  # end

  # # When user sends location message with label
  # on :label_location do |request|
  #   request.reply.text("Label: #{request[:Label]} Location_X: #{request[:Location_X]} Location_Y: #{request[:Location_Y]} Scale: #{request[:Scale]}")
  # end

  # # When user sends location
  # on :location do |request|
  #   request.reply.text("Latitude: #{request[:Latitude]} Longitude: #{request[:Longitude]} Precision: #{request[:Precision]}")
  # end

  on :event, with: 'unsubscribe' do |request|
    UserSignLog.unsubscribe_log request
    if request[:FromUserName] && (user = User.find_by(openid: request[:FromUserName]))
      # && user&.subscribe_status == 1 #已确认之前已关注用户不需要补钻石币
      user.with_lock do
        user.update_attributes!(subscribe_status: -1) # user can not receive this message
      end
    end
    request.reply.success
  end

  # # When user enters the app / agent app
  # on :event, with: 'enter_agent' do |request|
  #   request.reply.text "#{request[:FromUserName]} enter agent app now"
  # end

  # # When batch job "create/update user (incremental)" is finished.
  # on :batch_job, with: 'sync_user' do |request, batch_job|
  #   request.reply.text "sync_user job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  # end

  # # When batch job "replace user (full sync)" is finished.
  # on :batch_job, with: 'replace_user' do |request, batch_job|
  #   request.reply.text "replace_user job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  # end

  # # When batch job "invite user" is finished.
  # on :batch_job, with: 'invite_user' do |request, batch_job|
  #   request.reply.text "invite_user job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  # end

  # # When batch job "replace department (full sync)" is finished.
  # on :batch_job, with: 'replace_party' do |request, batch_job|
  #   request.reply.text "replace_party job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  # end

  # If no match above will fallback to below
  # on :fallback, respond: 'fallback message'
end
