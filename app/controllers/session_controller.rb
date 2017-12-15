class SessionController < ApplicationController
  skip_before_action :authenticate_user
  skip_before_action :verify_authenticity_token
  skip_before_action :verify_signature

  #用户登出
  def logout
    session.destroy
    redirect_to "/"
  end

  #用户登陆
  def login
    @title = "登录"
    render layout: "layouts/login"
  end

  #用户注册
  def register
    @title = "注册"
    render layout: "layouts/login"
  end

  #创建用户
  def create
    if params["code"] && params["password"] && params["phone"] &&  params["phone"].match(/^1\d{10}$/) && verify_rucaptcha_phone_code? && params[:accepter] == '1'
      user = User.new(phone: params[:phone], encrypted_password: params[:password], share_user_id: session[:share_user_id], nickname: params[:nickname] || params[:phone], accept_agreement: true)
      if user.save
        session[:user_id] = user.id
        render json: {status: 200, msg: "注册成功", data: {}}
      else
        render json: {status: 500, msg: "手机号已存在", data: {}}
      end
    else
      render json: {status: 500, msg: "手机号或手机验证码错误", data: {}}
    end
  end

  #用户授权
  def auth
    # verify_rucaptcha?  动态验证码
    if (SYSTEMCONFIG[:test] || verify_rucaptcha?) && params["phone"]  && params["password"]
      if user = User.login(params["phone"], params["password"])
        if user.status == -1
          render json:{status: 500, msg: "用户状态异常， 请联系客服#{SYSTEMCONFIG[:telephone_num]}"}
        else
          user.reset_auth_token! #重置token
          session[:user_id] = user.id

          # redirect_to params[:redirect_to] || "/"
          render json:{status: 200, msg: "登陆成功", data:{url: SYSTEMCONFIG[:host]+session[:redirect_to].to_s || SYSTEMCONFIG[:host], current_user: user.as_json} }
        end
      else
        render json:{status: 500, msg: "用户名或密码错误"}
      end
    else
      render json:{status: 500, msg: "用户名或图片验证码错误"}
    end
  end

  #发送验证码
  def send_verification_code
    if params["phone"] &&  params["phone"].match(/^1\d{10}$/)
      if Message.send_verification_code(params["phone"], request.remote_ip, params[:is_voice] == '1')
        render json: {status: 200, msg: "验证码已发送", data: {}}
      else
        render json: {status: 500, msg: "验证码发送频次过快，请稍后重试", data: {}}
      end
    else
      render json: {status: 500, msg: "手机号有误", data: {}}
    end
  end

  #发送验证码 带有验证码校验
  def send_verification_code_with_rucaptcha
    params[:is_voice] = '1'
    if verify_rucaptcha? && params["phone"] &&  params["phone"].match(/^1\d{10}$/)
      if Message.send_verification_code(params["phone"], request.remote_ip, params[:is_voice] == '1', 'rucaptcha')
        render json: {status: 200, msg: "验证码已发送", data: {}}
      else
        render json: {status: 500, msg: "验证码发送频次过快，请稍后重试", data: {}}
      end
    else
      render json: {status: 500, msg: "手机号或图片验证码有误", data: {}}
    end
  end

  #输入手机号发送验证码
  def verify_phone
  end

  #重设密码
  def reset_password
  end

  # 找回密码
  def get_pwd
    @title = '密码找回'
    # render layout: "layouts/login"
  end

  # 用户协议
  def agreement
    @title = '钻石大富翁用户协议'
  end


end
