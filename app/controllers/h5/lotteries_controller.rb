class H5::LotteriesController < ApplicationController
  before_action :set_lottery, only: [:show, :take_award, :set_consign_add, :formula_detail, :share_prize, :detail, :choose_address, :reward_detail, :next_step]
  skip_before_action :verify_signature
  skip_before_filter :verify_authenticity_token

  def machine
    @title = '公平管家'
    @lottery_order_items = LotteryOrderItem.where(lottery_id: params[:id], user_id: 0).pluck(:lottery_code)
    respond_to do |format|
      format.html
      format.json { render json: {status: 200, msg: '操作成功', data: {codes: @lottery_order_items}} }
    end
  end
  def choose_address
    @title = "选择收货地址"
    verify_win_user_lottery @lottery
    if params[:order_id]
      @lottery_order = LotteryOrder.find(params[:order_id])
    end
    @address = Address.where(:user_id => current_user.id, :status => 0)
    respond_to do |format|
      format.html
      format.json { render json: {status: 200, msg: '操作成功', data: {lottery: @lottery, address: @address, lottery_order: @lottery_order}} }
    end
  end
  #选完收货地址的下一步，改变order的状态为支付运费
  def next_step
    @lottery_order = @lottery.lottery_orders.where(is_win: true).first
    if @lottery_order && @lottery_order.user_id == current_user.id && @lottery.product_type.to_i == 1 && @lottery.product.postage.to_f != 0
        result = @lottery_order.update_attributes!(:status => 4,:address_id => params[:address])
      if result
        # 跳转中奖信息页面
        render json: {status: 600, alipay_url: 'url', lottery_order_id: @lottery_order.id, msg: '订单支付地址'}
      else
        render json: result
      end

    else
      render json: {status: 500, msg: "不是自己的获奖订单", data: {}}
    end
  end
  #设置收货地址
  def set_consign_add
    @lottery_order = @lottery.lottery_orders.where(is_win: true).first
    result = @lottery_order.update(:address_id => params[:address_id])
    if result
      render json: {status: 600, lottery_order_id: @lottery_order.id, msg: '地址修改成功'}
    else
      render json: {status: 500, lottery_order_id: @lottery_order.id, msg: '地址修改失败'}
    end
  end
  #中奖
  def reward_detail
    @title = "中奖信息"
    @lottery_order = LotteryOrder.where(lottery_id: @lottery.id, is_win: true, user_id: current_user.id).first
    @product = @lottery.product
    @address = Address.where(:user_id => current_user.id,:id => @lottery_order.address_id).first
    redirect_uri = CGI.escape("/home/share_open?product_id=#{@product.id}&share_user_id=#{current_user.id}")
    config_title = @product.is_bag? ? '玩钻联模拟盘，赢福袋，得大奖' : "幸运儿“#{current_user.nickname || current_user.phone}”，没错就是我！"
    img_url = @product.is_bag? ? 'default_image/share_lucky_bag.png' : @product.head_image

    if @product.is_bag?
      desc = "我在钻联分享福袋活动中，赢取了价值￥#{number_to_currency(@product.price)}的神秘大奖，你也来参加吧！"
    else
      desc = @product.product_second_type == 1 ? "我在钻联0元夺宝商城中，赢取了大奖，你也来参加夺宝吧！" : "我在钻联0元夺宝商城中，赢取了价值：￥#{number_to_currency(@product.price)}的大奖，你也来参加夺宝吧！"
    end
    @share_config = {
        title: config_title,
        desc: desc,
        link_url: "#{SYSTEMCONFIG[:host]}/share?redirect_uri=#{redirect_uri}&share_user_id=#{current_user.id}&local_url=#{CGI.escape(request.url)}",
        img_url: "#{SYSTEMCONFIG[:host]}#{img_url}",
    }
  end

  #领取奖品 填写收货地址
  def receive_prizes
    @title = "领取奖品"
    @lottery = Lottery.includes(:product).find(params[:id])
    verify_win_user_lottery @lottery
    get_lottery_order_address @lottery
    redirect_uri = CGI.escape("/home/share_open?product_id=#{@lottery.product_id}&share_user_id=#{current_user.id}")
    @share_config = {
        title: "玩钻联0元夺宝，免费赢大奖",
        desc: "我在钻联0元夺宝商城中，赢取了价值：￥#{ActiveSupport::NumberHelper.number_to_currency(@lottery.product.price, {unit: ''})}的大奖，你也来参加夺宝吧！",
        link_url: "#{SYSTEMCONFIG[:host]}/share?redirect_uri=#{redirect_uri}&share_user_id=#{current_user.id}&local_url=#{CGI.escape(request.url)}",
        img_url: "#{SYSTEMCONFIG[:host]}/default_image/WechatIMG42.png",
    }
    if @lottery.product_type == 2
      @share_config[:title] = "玩钻联模拟盘，赢福袋，得大奖"
      @share_config[:desc] = "我在钻联分享福袋活动中，赢取了价值￥#{ActiveSupport::NumberHelper.number_to_currency(@lottery.product.price, {unit: ''})}的神秘大奖，你也来参加吧！"
      @share_config[:img_url] = "#{SYSTEMCONFIG[:host]}/default_image/share_lucky_bag.png"
    end
  end

  #领取奖品
  def take_award
    @lottery_order = @lottery.lottery_orders.includes(:lottery, :product, :address).where(is_win: true).first
    if @lottery_order && @lottery_order.user_id == current_user.id
      result = @lottery_order.take_award(params, current_user)
      if result[:status].to_i == 600
        # 跳转支付
        #alipay_url = PayRecord.generate_alipay_wap_url @lottery_order
        render json: {status: 600, alipay_url: 'url', lottery_order_id: @lottery_order.id, msg: '订单支付地址'}
      else
        render json: result
      end

    else
      render json: {status: 500, msg: "不是自己的获奖订单", data: {}}
    end
  end

  def index
    @lottery_orders_exists = current_user.lottery_orders.exists?
    @lottery_index_alert = $cache.get("lottery_index_alert_#{current_user.id}").blank?
    if @lottery_orders_exists && current_user.total_diamond_coin < 10 && @lottery_index_alert
      $cache.set("lottery_index_alert_#{current_user.id}", 1, 24 * 3600)
      respond_to do |format|
        format.html { redirect_to "/home/get_diamonds?share_callback=1" }
        format.json { render json: {status: 500, msg: '用户钻石币不足', data: {}} }
      end
      # redirect_to "/home/get_diamonds?share_callback=1"
    else
      $cache.set("lottery_index_alert_#{current_user.id}", 1, 24 * 3600)
      @title = "钻石大富翁"
      unless params[:q]
        params[:q] = {}
      end
      if params[:q][:status_eq].blank? && params[:q][:status_gteq].blank?
        params[:q][:status_eq] = '0'
      end
      unless params[:q][:s]
        params[:q][:s] = "sort desc"
      end
      @lotteries = $cache.fetch("lotteries_index_#{params[:tag_id]}_#{params[:q].to_param}_#{params[:status]}_#{params[:page]}", 30) {
        unless params[:tag_id].blank?
          @q = Lottery.includes(:product, :win_user).where(product_type: 1, "products.product_tag_id": params[:tag_id].split(',')).where("published_at < ?", Time.now).ransack(params[:q])
          @lotteries = @q.result.page(params[:page]).to_a
        else
          @q = Lottery.includes(:product, :win_user).where(product_type: 1).where("published_at < ?", Time.now).ransack(params[:q])
          @lotteries = @q.result.page(params[:page]).to_a
        end
      }
      @tags = $cache.fetch("product_tag_data", 60){
        ProductTag.order(sort: :desc)
      }
      # binding.pry

      @notice = ShareConfig.show_notice

      respond_to do |format|
        format.html { render layout: "application" }
        format.json { render json: {data: {lotteries: @lotteries, tags: @tags, user_coin: current_user.reload.total_diamond_coin, notice: @notice}, status: 200, msg: '操作成功'} }
      end
    end
  end

  def formula_detail
    if @lottery.status == 2
      if @lottery.product_type == 1
        @title = "已揭晓宝贝"
      else
        @title = "已揭晓福袋"
      end
    else
      if @lottery.product_type == 1
        @title = "夺宝详情"
      else
        @title = "福袋详情"
      end
    end
  end
  def detail
    @title = "夺宝记录详情"
    @lottery_order = LotteryOrder.where(lottery_id: @lottery.id).first
    @product = @lottery.product
    @address = Address.where(:user_id => current_user.id,:is_default => true).first

    json_data = detail_data(@lottery, @product, @address)
    respond_to do |format|
      format.html
      format.json { render json: {data: json_data, status: 200, msg: '操作成功'}}
    end
  end


  def show

    redirect_to "/h5/lotteries" if @lottery.published_at > Time.now
    if @lottery.product_type == 2 && @lottery.status == 0
      redirect_to "/h5/lotteries"
    end
    if @lottery.status == 0
      @title = "夺宝详情"
    elsif @lottery.status == 1
      @title = "待开奖"
    else
      if @lottery.product_type == 2
        @title = "已揭晓福袋"
      else
        @title = "已揭晓宝贝"
      end
    end
    @product = @lottery.product
    # @lottery_order_items = @lottery.lottery_order_items
    @self_lottery_order_items = @lottery.lottery_order_items.where(user_id: current_user.id)
    if @lottery.status == 2
      @win_user = User.find(@lottery.win_user_id)
      @total_buy = @win_user.lottery_order_items.where(lottery_id: @lottery.id).count
    end

    @can_lottery = @lottery.can_lottery?(current_user)
    @user_left_count = @lottery.user_left_count(current_user.id)
    @max_count = [(current_user.total_diamond_coin / @lottery.price).to_i, @lottery.left_count, @user_left_count, 200].min


    if @lottery.status == 0 || @lottery.status == 1
      redirect_uri = CGI.escape("/home/share_open?share_user_id=#{current_user.id}")
      @share_config = {
          title: "还有#{@lottery.left_count}人次就知道幸运儿是谁！",
          desc: "这是一个收获“#{@product.name}”的地方！",
          link_url: "#{SYSTEMCONFIG[:host]}/share?redirect_uri=#{redirect_uri}&share_user_id=#{current_user.id}&local_url=#{CGI.escape(request.url)}",
          img_url: "#{SYSTEMCONFIG[:host]}/#{@product.head_image}",
      }
    else
      if @win_user&.id == current_user.id
        redirect_uri = CGI.escape("/home/share_open?product_id=#{@product.id}&share_user_id=#{current_user.id}")
      else
        redirect_uri = CGI.escape("/home/share_open?share_user_id=#{current_user.id}")
      end
      @share_config = {
          title: "幸运儿“#{@win_user.nickname}”，没错就是我！",
          desc: "拿到“#{@product.name}”就是爽！",
          link_url: "#{SYSTEMCONFIG[:host]}/share?redirect_uri=#{redirect_uri}&share_user_id=#{current_user.id}&local_url=#{CGI.escape(request.url)}",
          img_url: "#{SYSTEMCONFIG[:host]}/#{@product.head_image}",
      }
    end

    if @product.product_type == 2
      @share_config[:title] = "玩钻联模拟盘，赢福袋，得大奖"
      @share_config[:desc] = "我在钻联分享福袋活动中，赢取了价值￥#{ActiveSupport::NumberHelper.number_to_currency(@product.price, {unit: ''})}的神秘大奖，你也来参加吧！"
      @share_config[:img_url] = "#{SYSTEMCONFIG[:host]}/default_image/share_lucky_bag.png"
    end
  end

  def buy_record
    @title = '夺宝记录'
    index = params[:index].blank? ? '0' : params[:index]
    if index == '0'
      @lotteries = Lottery.includes(:product, :win_user, :lottery_orders).where(status: [0,1], "lottery_orders.user_id" => current_user.id).order(created_at: :desc).paginate(page: params[:page] || 1)
    elsif index == '1'
      @lotteries = Lottery.includes(:product, :win_user, :lottery_orders).where(status: 2, "lottery_orders.user_id" => current_user.id).order(created_at: :desc).paginate(page: params[:page] || 1)
    else
      @lotteries = Lottery.includes(:product, :win_user, :lottery_orders).where(status: 2, "lottery_orders.user_id" => current_user.id,:win_user_id => current_user.id).order(created_at: :desc).paginate(page: params[:page] || 1)
    end

    # Lottery.includes(:lottery_orders).where("lottery_orders.user_id" => current_user.id).ransack(params[:q])

    respond_to do |format|
      format.html
      format.json { render json: {data: @lotteries.as_json(Lottery.buy_record_xml_options), status: 200, msg: '操作成功'} }
    end

  end


  def lucky_package
    @title = "我的福袋"
    @lottery_orders = LotteryOrder.where(user_id: current_user.id)
    if params[:status].blank? || params[:status] == '0'
      @lotteries = Lottery.includes(:product, :win_user).where(product_type: 2, user_id: current_user.id).order(created_at: :desc).paginate(:page => params[:page] || 1)
    else
      @lotteries = Lottery.includes(:product, :win_user).where(product_type: 2, status: params[:status].split(',')).order(created_at: :desc).paginate(:page => params[:page] || 1)
    end
    respond_to do |format|
      format.html
      format.json { render json: {data: @lotteries, status: 200} }
    end
  end

  def lucky_package_share
    @title = "福袋活动"
    @lottery = Lottery.where(user_id: current_user.id, id: params[:id]).first
    unless @lottery
      redirect_to "/" and return
    end
    redirect_uri = CGI.escape("/h5/lotteries/#{@lottery.id}/lucky_package_join?share_code=#{@lottery.share_code}")
    @share_config = {
        title: "领钻联福袋，得神秘大奖",
        desc: "您的好友#{current_user.nickname}，给您分享了价值：￥#{ActiveSupport::NumberHelper.number_to_currency(@lottery.product.price, {unit: ''}) }的钻联福袋，参与抽奖，可得神秘大礼！",
        link_url: "#{SYSTEMCONFIG[:host]}/share?redirect_uri=#{redirect_uri}&share_user_id=#{current_user.id}&local_url=#{CGI.escape(request.url)}",
        img_url: "#{SYSTEMCONFIG[:host]}/default_image/share_lucky_bag.png",
    }
    render layout: "layouts/login"
  end

  def lucky_package_join
    @title = "福袋活动"
    if params[:share_code] && params[:id] && @lottery = Lottery.where(share_code: params[:share_code], id: params[:id]).first
      render layout: "layouts/login"
    else
      redirect_to "/"
    end
  end

  def lucky_package_open
    @title = "福袋活动"
    if params[:share_code] && params[:id] && @lottery = Lottery.where(share_code: params[:share_code], id: params[:id]).first
      @lottery_orders = @lottery.lottery_orders
      if !LotteryOrder.where(user_id: current_user.id, lottery_id: @lottery.id).exists? && current_user.id != @lottery.user.id && $redis.sadd("lucky_package_open_#{@lottery.id}", current_user.id)
        $redis.expire("lucky_package_open_#{@lottery.id}", 3600)
        @lottery.lottery_order_create(current_user, 1, request.ip)
      end
      @current_user_lottery_order_item = @lottery.lottery_order_items.where(user_id: current_user.id).first
      @win_user = @lottery.win_user
      render layout: "layouts/login"
    else
      redirect_to "/"
    end
  end

  def share_prize
    @product = @lottery.product
    @title = '领取奖品'
    redirect_uri = CGI.escape("/home/share_open?product_id=#{@product.id}&share_user_id=#{current_user.id}")
    config_title = @product.is_bag? ? '玩钻联模拟盘，赢福袋，得大奖' : "幸运儿“#{current_user.nickname || current_user.phone}”，没错就是我！"
    img_url = @product.is_bag? ? 'default_image/share_lucky_bag.png' : @product.head_image

    if @product.is_bag?
      desc = "我在钻联分享福袋活动中，赢取了价值￥#{number_to_currency(@product.price)}的神秘大奖，你也来参加吧！"
    else
      desc = @product.product_second_type == 1 ? "我在钻联0元夺宝商城中，赢取了大奖，你也来参加夺宝吧！" : "我在钻联0元夺宝商城中，赢取了价值：￥#{number_to_currency(@product.price)}的大奖，你也来参加夺宝吧！"
    end
    @share_config = {
        title: config_title,
        desc: desc,
        link_url: "#{SYSTEMCONFIG[:host]}/share?redirect_uri=#{redirect_uri}&share_user_id=#{current_user.id}&local_url=#{CGI.escape(request.url)}",
        img_url: "#{SYSTEMCONFIG[:host]}#{img_url}",
    }
  end

  def buy_record_append
    @lottery_orders = LotteryOrder.includes(:user, :couriers, :lottery, :product, :lottery_order_items).where(user_id: current_user.id).where.not(status: -1).order(created_at: :desc).paginate(:page => params[:page] || 1, :per_page => 10)
    return render partial: 'record_append'
  end

  def alert_get_diamond
    $cache.set("get_diamond_user_#{current_user.id}", 1, 24 * 3600)
    return render json: {status: 200}
  end

  # 最新订单
  def newly_orders
    @new_ten_orders = $cache.fetch("newly_orders_now", 30){
      @new_ten_orders = Lottery.includes(:win_user, :product).where(status: 2).order(lottery_time: :desc).limit(10).to_a
    }
  end

  # 夺宝记录api
  def buy_record_page
    @lottery_orders = LotteryOrder.includes(:user, :couriers, :lottery, :product, :lottery_order_items).where(user_id: current_user.id).where.not(status: -1).order(created_at: :desc).paginate(:page => params[:page] || 1, :per_page => 10)
    # respond_to do |format|
    #   format.json { render json: {data: {diamond_accounts: @lottery_orders}, status: 200} }
    # end
  end

  # 夺宝详情api
  def lottery_detail
    @lottery = Lottery.where("id = ?", params[:lottery_id].to_i).first
    return render json: {status: 500, msg: '没找到对应夺宝期次', data: {}} if @lottery.blank?
    if params[:format] == 'json' && (@lottery.published_at > Time.now || (@lottery.product_type == 2 && @lottery.status == 0))
      return render json: {status: 500, msg: '无权限', data: {}}
    end
    @product = @lottery.product
    @self_lottery_order_items = @lottery.lottery_order_items.where(user_id: current_user.id)
    if @lottery.status == 2
      @win_user = User.find(@lottery.win_user_id)
      @total_buy = @win_user.lottery_order_items.where(lottery_id: @lottery.id).count
    end

    @can_lottery = @lottery.can_lottery?(current_user)
    @user_left_count = @lottery.user_left_count(current_user.id)
    @max_count = [(current_user.total_diamond_coin / @lottery.price).to_i, @lottery.left_count, @user_left_count, 200].min
  end

  # 夺宝记录详情api数据
  def detail_data(lottery, product, address)
    product_images = []
    if product.product_type == 1
      product_images = product.images.map{|image| SYSTEMCONFIG[:cdn_host]+image.url}
    end
    if product.product_type == 2
      product_images = [SYSTEMCONFIG[:cdn_host]+product.head_image]
    end

    json_data = {lottery: lottery.as_json, product_images: product_images}
  end

  private
  def set_lottery
    @lottery = Lottery.includes(:lottery_order).find(params[:id])
  end


  def get_lottery_order_address lottery
    @lottery_order = LotteryOrder.includes(:address).where(is_win: true,lottery_id: lottery.id).first
    if @lottery_order && @lottery_order.user_id == current_user.id
      @address = @lottery_order.address
    end

  end


  #验证是否为当前登录用户的中奖订单
  def verify_win_user_lottery lottery
    if lottery.win_user_id != current_user.id
      redirect_to "/h5/lotteries"
    end
  end

end
