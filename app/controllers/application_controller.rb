class ApplicationController < ActionController::Base
  wechat_responder
  # wechat_api
  protect_from_forgery with: :exception

  before_action :authenticate_user
  before_action :set_nocache_header
  # before_action :wechat_share_config
  helper_method :current_user, :wechat_browser?

  layout "login"

  def wechat_share_config
    @share_config = ShareConfig.random_config(current_user)
    redirect_uri = CGI.escape("/home/share_open?share_user_id=#{current_user.id}&share_config_id=#{@share_config['id']}")
    @share_config[:link_url] = "#{SYSTEMCONFIG[:host]}/share?redirect_uri=#{redirect_uri}&share_user_id=#{current_user.id}&local_url=#{CGI.escape(request.url)}"
    @share_config[:img_url] = "#{SYSTEMCONFIG[:host]}/default_image/share.png?419"
    @share_config = @share_config.with_indifferent_access
  end

  def set_nocache_header
    response.header["Cache-Control"] = "no-cache,no-store,must-revalidate"
    response.header["Pragma"] = "no-cache"
    response.header["Expires"] = 0
  end

  def wechat_browser?
    request.env["HTTP_USER_AGENT"].match("MicroMessenger")
  end

  #手机短信验证码， 不带动态图片验证码的
  def verify_phone_code?
    $cache.get(params["phone"]) == params["code"] && !params["code"].blank?
  end
  #手机短信验证码， 带动态图片验证码的
  def verify_rucaptcha_phone_code?
    $cache.get("rucaptcha_"+params["phone"]) == params["code"] && !params["code"].blank?
  end

  def current_user
    begin
      @currnet_user ||= User.find(session[:user_id])
    rescue Exception => e
      nil
    end
  end

  def authenticate_user
    unless request.headers["HTTP_AUTHENTICATIONTOKEN"].blank?
      session[:user_id] = User.find_user_id_by_authentication_token(request.headers["HTTP_AUTHENTICATIONTOKEN"])
    end
    if session[:user_id]
      wechat_share_config
      return
    end
    if(request.headers["HTTP_APPCLIENT"])
      render json:{status: 406,  msg: "授权失败"} and return
    end
    session[:share_user_id] = params[:share_user_id] if params[:share_user_id]
    # 微信浏览器默认微信授权
    if request.env["HTTP_USER_AGENT"].match("MicroMessenger")
      wx_auth
    else
      phone_auth
    end
  end

  def phone_auth
    session[:redirect_to] = request.original_fullpath
    redirect_to "/login?redirect_to=#{CGI.escape(request.original_fullpath)}"
  end


  def wx_auth
    Rails.logger.info("*"*100)
    Rails.logger.info(params)
    wechat_oauth2("snsapi_userinfo") do |openid, access_info|
      if @current_user = User.find_by(openid: openid)
        if @current_user.status == -1
          redirect_to "/500.html"
        else
          session[:user_id] = @current_user.id
        end
      else
        userinfo = wechat.web_userinfo(access_info["access_token"], openid)
        @current_user = User.create(userinfo.with_indifferent_access.slice( :province, :openid, :nickname, :sex, :city, :country, :headimgurl, :unionid).merge({total_gold: SYSTEMCONFIG[:admin_config][:user_register][:gold], available_gold: SYSTEMCONFIG[:admin_config][:user_register][:gold]}).merge({share_user_id:  params[:share_user_id] || session[:share_user_id]}))
        session[:user_id] = @current_user.id
      end
    end
  end

  #为 number_to_currency 增加默认值
  def number_to_currency number, options = {}
    options[:unit] = "" if options[:unit].blank?
    ActiveSupport::NumberHelper.number_to_currency(number, options)
  end

end
