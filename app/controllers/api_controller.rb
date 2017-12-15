class ApiController < ActionController::Base
  wechat_responder appid: "wxaf18be35dd9e8498", secret: "55ca0720e098263e6ca14b863ec80a18"
  def get_state
  end

  def wx_auth
    Rails.logger.info("*"*100)
    Rails.logger.info(params)
    wechat.jsapi_ticket.ticket if wechat.jsapi_ticket.oauth2_state.nil?
    params[:state] = wechat.jsapi_ticket.oauth2_state
    wechat_oauth2("snsapi_userinfo") do |openid, access_info|
      if @current_user = User.find_by(openid: openid)
        if @current_user.status == -1
          render json: {status: 407, msg: "用户被禁止登陆"}
        else
          session[:user_id] = @current_user.id
          render json: {status: 200, msg: "登陆成功", data:{current_user: @current_user.as_json} }
        end
      else
        userinfo = wechat.web_userinfo(access_info["access_token"], openid)
        @current_user = User.create(userinfo.with_indifferent_access.slice( :province, :openid, :nickname, :sex, :city, :country, :headimgurl, :unionid).merge({total_gold: SYSTEMCONFIG[:admin_config][:user_register][:gold], available_gold: SYSTEMCONFIG[:admin_config][:user_register][:gold]}).merge({share_user_id:  params[:share_user_id] || session[:share_user_id]}))
        session[:user_id] = @current_user.id
        render json: {status: 200, msg: "登陆成功", data:{current_user: @current_user.as_json} }
      end
    end
  end

end
