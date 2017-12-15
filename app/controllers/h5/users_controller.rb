class H5::UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :binding_phone, :exchange_coin, :change_avatar]
  before_action :check_verify, only: :update
  before_action :action_params, only: :update
  # before_action :change_avatar, only: :update

  skip_before_action :verify_signature
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user, only: [:verify_code]

  def alert_binding_phone
    $cache.set("user_binding_phone_#{current_user.id}", 1, 24 * 3600)
    render json: {status: 200}
  end

  #初始化用户模拟盘数据 仅测试可用
  def init_diamond_info
    if SYSTEMCONFIG[:test]
      current_user.init_diamond_info
    end
    redirect_to "/"
  end

  # GET /users/1
  # GET /users/1.json
  def home
    @title = '我的'
    # 拥有的数量，有效期内可用的，0个页面不显示数字，暂时取消了
    # @lottery_count = $cache.fetch("lottery_count_user#{current_user.id}", 60){
    #   current_user.lotteries.where("end_time > ? and status <> ?", Time.now, -1).count
    # }
    # @coin_bag_count = $cache.fetch("coin_bag_count_user#{current_user.id}", 60){
    #   current_user.coin_bag_lotteries.where("end_time > ? and remain_coin_count > 0", Time.now).count
    # }
    render layout: "application"
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    code_ok = @need_code ? verify_phone_code? : true
    if code_ok && @can_verify && current_user.update(user_params)
      return render json: {status: 200, msg: '修改成功', data: {}}
    else
      return render json: {status: 500, msg: (@msg.present? ? @msg : '验证码错误'), data: {}}
    end
  end

  def binding_phone
    @title = '绑定手机号'
  end

  def get_verification_code
    @title = "获取验证码"
    render layout: 'login'
  end

  def verify_code
    user_id = User.where("phone = ?", params[:phone].strip).first.try(:id) || current_user.try(:id)
    if verify_phone_code? && user_id.present?
      $cache.set("verifyed_#{user_id}", true, 10*60)
      session[:user_id] = user_id
      return render json: {status: 200, msg: '校验成功', data: {user_id: user_id}}
    else
      return render json: {status: 500, msg: '校验失败', data: {user_id: user_id.blank? ? 0 : user_id}}
    end
  end

  def modify_password
    @title = params[:from] == 'get_pwd' ? "密码找回" : '修改密码'
  end


  # 保存头像
  def change_avatar
    file = params[:avatar_file].tempfile
    image = MiniMagick::Image.open(file.path)
    if params[:avatar_data].present?
      size_info = JSON.parse(params[:avatar_data]) rescue JSON.parse(params[:avatar_data].to_json)
      image.crop "#{size_info['width']}x#{size_info['height']}+#{size_info['x']}+#{size_info['y']}"
    end
    image.resize "100x100"
    # image.write "output.png"

    uploader = HeadimgUploader.new
    uploader.store!(image)
    url = uploader.url

    params[:user] ||= {}
    params[:user][:headimgurl] = url
    if current_user.update(user_params)
      # GoldGainsHistory.refresh_user_datas(@user.id) #有竞赛的时候要加上，更新头像
      return render json: {status: 200, msg: '头像修改成功', data: {}}
    else
      return render json: {status: 500, msg: '头像修改失败', data: {}}
    end
  end

  # 邀请记录
  def invite_history
    @title = '邀请记录'
    @diamond_accounts = current_user.invited_users
  end

  def invite_history_page
    @title = '邀请记录'
    @diamond_accounts = current_user.invited_users.paginate(:page => params[:page], :per_page => 10).to_a
    # @diamond_accounts = $cache.fetch("invite_history_user#{current_user.id}", 30){
    #   # current_user.invited_users.page(params[:page]).to_a
    #   current_user.invited_users.paginate(:page => params[:page], :per_page => 10).to_a
    # }

    respond_to do |format|
      format.html { render layout: "application" }
      format.json { render json: {data: {diamond_accounts: @diamond_accounts}, status: 200} }
    end
  end

  # 执行钻石币兑换
  def exec_coin
    return render json: {status: 500, msg: '数据错误', data: {}} if params[:num].blank?
    coin_num = params[:num].strip
    gold_num = coin_num.to_i * SYSTEMCONFIG[:admin_config][:diamond_exchange_rate]
    return render json: {status: 500, msg: '今日已达到兑换上限，请明日再来', data: {}} if current_user.left_exc_coin_num_today[:has_exchanged] >= SYSTEMCONFIG[:admin_config][:exchange][:day_limit]
    # 虚拟资金不足不饿能兑换

    left_gold = ((current_user.available_gold - gold_num) - SYSTEMCONFIG[:admin_config][:user_register][:gold])
    if left_gold < 0 || (current_user.available_gold - SYSTEMCONFIG[:admin_config][:user_register][:gold]) < SYSTEMCONFIG[:admin_config][:diamond_exchange_rate]
      return render json: {status: 500, msg: "兑换失败<br>当前可用资金不足", data: -1}
    end
    return render json: {status: 500, msg: '兑换失败', data: {}} if (coin_num.blank? || coin_num.to_i <= 0 || coin_num.to_i > SYSTEMCONFIG[:admin_config][:exchange][:day_limit])
    # 创建gold_account \ diamond_account
    begin
      current_user.g_exchange_coins!(coin_num, gold_num)
      return render json: {status: 200, msg: '兑换成功', data: {}}
    rescue Exception => e
      return render json: {status: 500, msg: '兑换失败', data: {}}
    end

  end

  # 法律声明
  def law_illustration
    @title = '法律声明'
  end

  def check_diamond_coin
    @can_exchange = current_user.left_exc_coin_num_today
    @diamond_exchange_rate = SYSTEMCONFIG[:admin_config][:diamond_exchange_rate]
    return render json: {status: 200, msg: '操作成功', data: {can_exchange: @can_exchange, diamond_exchange_rate: @diamond_exchange_rate}}
  end


  def my_all_record
    @title = '记录查询'
  end


  def my_profile
    @title = '个人资料'
  end

  def nickname_new
    @title = '修改昵称'
  end


  def nickname_update
    @title = '修改昵称'
    nickname = params[:nickname]
    if nickname.length > 32 || nickname.blank?
      flag = {status: 500, msg: '操作失败,昵称长度有误', data: {msg: '昵称长度不能超过32'}}
    else
      current_user.update_attributes(nickname: nickname)
      flag = {status: 200, msg: '操作成功', data: {msg: '修改成功'}}
    end
    render json: flag
  end




  # API接口
  def diamond_coin_api
    @can_exchange = current_user.left_exc_coin_num_today
    @diamond_exchange_rate = SYSTEMCONFIG[:admin_config][:diamond_exchange_rate]
    useful_gold = current_user.available_gold - SYSTEMCONFIG[:admin_config][:user_register][:gold]
    can_change = useful_gold > 0 ? (useful_gold / SYSTEMCONFIG[:admin_config][:diamond_exchange_rate]).to_i : 0
    render json: {status: 200, msg: '操作成功', data: {can_exchange: @can_exchange[:can_exchange], has_exchanged: @can_exchange[:has_exchanged], day_exchange_max: SYSTEMCONFIG[:admin_config][:exchange][:day_limit], can_exchange_max: can_change}}
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:phone, :encrypted_password, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :province, :openid, :nickname, :sex, :city, :country, :headimgurl, :unionid, :accept_agreement)
  end

  def action_params
    arr = ['binding_phone']
    @need_code = params[:action_type].in?(arr)
    params[:phone] = @need_code ? params[:phone] : ''
    params[:code] = @need_code ? params[:code] : ''
  end

  def check_verify
    if params[:action_type] == 'modify_password'
      @can_verify = ($cache.get("verifyed_#{current_user.id}") && params[:password].present? && params[:password] == params[:password_confirmation]) ? true : false
      @msg = '修改失败' if params[:password].strip.length == 0 || params[:password_confirmation].strip.length == 0
      params[:user] ||= {}
      params[:user][:encrypted_password] = params[:password]
    elsif params[:action_type] == 'binding_phone'
      user = User.where("phone = ?", params[:phone]).first
      if !user.blank?
        @msg = "该手机号已经被使用"
        @can_verify = false
      else
        params[:user] ||= {}
        params[:user][:phone] = params[:phone]
        @can_verify = true
      end
    else
      @can_verify = true
    end
  end

end
