class HomeController < ApplicationController
  # skip_before_action :authenticate_user
  skip_before_filter :verify_authenticity_token
  skip_before_action :verify_signature
  skip_before_action :authenticate_user, only: [:share]
  # before_action :generate_rank_data, only: [:index]
  # skip_before_action :authenticate_user
  before_action :create_login_log

  #赚币首页
  def get_diamonds
    @share_count = $cache.fetch("user_share_count_#{current_user.id}", 6){
      ShareItem.where(user_id: current_user.id).where("created_at > '#{Date.today.to_s}'").count
    }
    @invite_user_count = $cache.fetch("invite_user_count_#{current_user.id}", 6){
      User.where(share_user_id: current_user.id).count
    }
    json_data = diamond_index_api(@share_count, @invite_user_count)
    respond_to do |format|
      format.html { render layout: "application" }
      format.json { render json: {data: json_data, status: 200, msg: '操作成功'} }
    end
  end

  #获取夺宝机会
  def get_diamond
    @title = "秒获夺宝机会"
    wechat_share_config
  end

  def phone_code
    if SYSTEMCONFIG[:test]
      if params[:phone]
        render json: {status: 200, data: $cache.get(params[:phone])}
      else
        render json: {status: 500, msg: "手机号不正确"}
      end
    else
      render json: {status: 500, msg: "forbidden"}
    end
  end


  def share
    session[:share_user_id] = params[:share_user_id]
    if params["redirect_uri"]
      redirect_to params["redirect_uri"]
    else
      redirect_to "/"
    end
  end

  def share_callback
    begin
      ShareItem.create(params[:data].merge({user_id: current_user.id}).permit(:user_id, :controller, :action, :share_id, :share_type, :share_config_id))
      @share_count = $cache.fetch("user_share_count_#{current_user.id}", 6){
        ShareItem.where(user_id: current_user.id).where("created_at > '#{Date.today.to_s}'").count
      }
      render json: {status: 200, data: {coin: current_user.reload.total_diamond_coin.to_i, share_count: (@share_count > 5 ? 5 : @share_count)}, msg: '操作成功'}

    rescue Exception => e
      render json: {status: 500, msg: '数据错误', data: {error: params[:data] }}
    end

  end

  def share_open
    session[:share_user_id] = params[:share_user_id] if params[:share_user_id]
    if(current_user.lottery_orders.exists?)
      if current_user.total_diamond_coin > 10
        if params[:local_url]
          redirect_to "#{params[:local_url]}?share_callback=1&share_user_id=#{params[:share_user_id]}"
        else
          redirect_to "/?share_callback=1&share_user_id=#{params[:share_user_id]}"
        end
      else
        redirect_to "/home/get_diamonds?share_callback=1&share_user_id=#{params[:share_user_id]}"
      end
    else
      lottery = Lottery.where(status: 0, product_type: 1).order("sort desc").limit(2).last
      redirect_to "/h5/lotteries/#{lottery.id}?share_callback=1&share_user_id=#{params[:share_user_id]}"
    end
    # if wechat_browser?
    #   authenticate_user
    # end
    # session[:share_user_id] = params[:share_user_id] if params[:share_user_id]
    # @share_user = User.find(params[:share_user_id])
    # @product = Product.find(params[:product_id]) if params[:product_id]
  end

  #用户挂单页面
  def pending_trade
  end

  #用户首页
  def index
    @title = "钻石模拟盘"
    @sale_diamonds = $cache.fetch("sale_diamonds", 60) {
      SaleDiamond.where(is_published: true).to_a
    }
    @sale_diamonds_price =SaleDiamond.current_prices

    @hold_diamonds_count = HoldDiamond.user_diamonds(current_user.id).count

    shorting_diamond_trades =DiamondTrade.where(close_shorting_status: [0, 1], user_id: current_user.id, bussiness_type: 3).to_a

    @shorting_diamonds_count = shorting_diamond_trades.sum(&:total_count)

    # @booking_sell_diamonds_count = HoldDiamond.user_diamonds(current_user.id).select { |x| x.status == 0 }.count

    @hold_diamonds = HoldDiamond.hold_diamonds_info(current_user.id)
    @hold_diamonds.default=0
    @shorting_diamonds = Hash.new(0)
    shorting_diamond_trades.each do |trade|
      @shorting_diamonds[trade.sale_diamond_id] += trade.total_count
    end
    @total_assets = current_user.total_gold + @hold_diamonds.inject(0) { |sum, kv| sum += (@sale_diamonds_price[kv[0]] * kv[1]) rescue 0 } + shorting_diamond_trades.inject(0) { |sum, x| sum += (2 * x.price - @sale_diamonds_price[x.sale_diamond_id]) * x.total_count }

    @diamond_trade_count = current_user.diamond_trades.where("created_at > '#{Time.now.beginning_of_day}'").count

    @box = {
        trade_count: SYSTEMCONFIG["admin_config"]["box"]["trade_count"],
        gold: SYSTEMCONFIG["admin_config"]["box"]["gold"],
        current_count: @diamond_trade_count,
        is_open: current_user.trade_boxs.where(day: Date.today.to_s).exists?,
    }
    redirect_uri = CGI.escape("/home/share_open?share_user_id=#{current_user.id}")

    # @win = RankingConfig.check_rank(current_user) # 竞赛部分，暂时注释

    # render layout: "application"

    json_data = get_diamond_datas(@total_assets, @shorting_diamonds_count, @hold_diamonds_count, @sale_diamonds, @hold_diamonds, @shorting_diamonds, @sale_diamonds_price)

    respond_to do |format|
      format.html { render layout: "application" }
      format.json { render json: {data: json_data, status: 200, msg: '操作成功'} }
    end
  end

  # 模拟盘页面主要json数据
  def get_diamond_datas(total_assets, shorting_diamonds_count, hold_diamonds_count, sale_diamonds, hold_diamonds, shorting_diamonds, sale_diamonds_price)
    total_asset = number_to_currency total_assets
    available_gold = number_to_currency current_user.available_gold
    hold_count = shorting_diamonds_count + hold_diamonds_count
    # binding.pry
    profit = number_to_currency(total_assets - SYSTEMCONFIG["admin_config"]["user_register"]["gold"].to_i)

    diamonds = []
    sale_diamonds.each do |sale_diamond|
      count = hold_diamonds[sale_diamond.id] + shorting_diamonds[sale_diamond.id]
      hold_count = count > 0 ? count : nil
      name = sale_diamond.cn_name
      price = number_to_currency( sale_diamonds_price[sale_diamond.id] || 0 )
      exchange_name = sale_diamond.exchange_name
      increase = number_to_currency(sale_diamonds_price[sale_diamond.id] - sale_diamond.yesterday_close_pirce)
      diamonds << {hold_count: hold_count, name: name, price: price, exchange_name: exchange_name, increase: increase, yesterday_close_pirce: number_to_currency(sale_diamond.yesterday_close_pirce), max_price: number_to_currency(sale_diamond.max_price), opening_price: number_to_currency(sale_diamond.opening_price), min_price: number_to_currency(sale_diamond.min_price)}
    end
    json_data = {total_assets: total_assets, available_gold: available_gold, hold_count: hold_count, profit: profit,total_diamond_coin: current_user.total_diamond_coin, diamonds: diamonds}
    return json_data
  end

  # 赚币页面数据接口
  def diamond_index_api(share_count, invite_user_count)
    data = {day_sign_diamond: SYSTEMCONFIG[:admin_config][:day_sign][:diamond_account], share_diamond: SYSTEMCONFIG[:admin_config][:wechat_share][:diamond_account], share_limit: SYSTEMCONFIG[:admin_config][:wechat_share][:limit], invite_diamond: SYSTEMCONFIG[:admin_config][:invite_user_each][:diamond_account], share_count: share_count, invite_user_count: invite_user_count, sign_state: current_user.day_signed?, total_diamond_coin: current_user.total_diamond_coin}
    return data
  end

  # app获取登录用户信息
  def user_info_api
    if current_user.blank?
      render json: {status: 500, msg: '登录已过期', data: {}}
    else
      render json: {status: 200, msg: '操作成功', data: {current_user: current_user.as_json}}
    end
  end



  private

  #记录用户登录天数，每天仅保存一条
  def create_login_log
    begin
      if $redis.sadd("login_log#{Time.now.strftime("%Y%m%d")}", current_user.id)
        # if wechat_browser?

        # end
        UserLoginLog.create(user_id: current_user.id, login_date: Time.now, request_ip: request.remote_ip)
        $redis.expire("login_log#{Time.now.strftime("%Y%m%d")}",60*60*8)
      end
    rescue Exception => e
      nil
    end


  end

  def generate_rank_data
    GoldGainsHistory.generate_rank_data(current_user.id)
  end

end
