class H5::CoinBagLotteriesController < ApplicationController
  def index
    @title = "钻币礼包"
    @coin_bag_lotteries = CoinBagLottery.where(user_id: current_user.id).where("end_time > ? and remain_coin_count > 0 ", Time.now).order(created_at: :desc)
  end

  def share
    @title = "钻币礼包"
    @coin_bag_lottery = CoinBagLottery.where(id: params[:id], user_id: current_user.id).first
    if @coin_bag_lottery
      redirect_uri = CGI.escape("/h5/coin_bag_lotteries/#{@coin_bag_lottery.id}/share_open?share_code=#{@coin_bag_lottery.share_code}")
      @share_config = {
        title: "抢钻联钻币礼包，参与夺宝，赢大奖",
        desc: "您的好友#{current_user.nickname}，给您分享了钻币礼包，领取钻石币，参与夺宝，赢大奖！",
        link_url: "#{SYSTEMCONFIG[:host]}/share?redirect_uri=#{redirect_uri}&share_user_id=#{current_user.id}&local_url=#{CGI.escape(request.url)}",
        img_url: "#{SYSTEMCONFIG[:host]}/default_image/share_package.png",
      }
      render layout: "layouts/login"
    else
      redirect_to "/"
    end
  end

  def share_open
    @title = "钻币礼包"
    @coin_bag_lottery = CoinBagLottery.where(id: params[:id], share_code: params[:share_code]).first
    if @coin_bag_lottery
      @share_user = @coin_bag_lottery.user
      render layout: "layouts/login"
    else
      redirect_to "/"
    end
  end

  def share_open_result
    @title = "钻币礼包"
    @coin_bag_lottery = CoinBagLottery.where(id: params[:id], share_code: params[:share_code]).first
    if @coin_bag_lottery
      @coin_bag_lottery_item = @coin_bag_lottery.coin_bag_lottery_items.where(user_id: current_user.id).first
      if !@coin_bag_lottery_item && $redis.sadd("share_open_result_#{@coin_bag_lottery.id}", current_user.id)
        $redis.expire("share_open_result_#{@coin_bag_lottery.id}",3600)
        r = @coin_bag_lottery.get_cron_count
        if r
          @coin_bag_lottery_item = @coin_bag_lottery.coin_bag_lottery_items.create(coin_bag_id: @coin_bag_lottery.coin_bag_id, user_id:current_user.id, request_ip: request.ip, coin_count: r)
        else
          @coin_bag_lottery.update(remain_coin_count: 0)
        end
        # @coin_bag_lottery.with_lock do
        #   @coin_bag_lottery.update_attributes!(remain_coin_count: @coin_bag_lottery.remain_coin_count - r)
        # end
      end
      @coin_bag_lottery_items = @coin_bag_lottery.coin_bag_lottery_items.includes(:user).order(created_at: :desc)
      @share_user = @coin_bag_lottery.user
      render layout: "layouts/login"
    else
      redirect_to "/"
    end
  end
end
