class H5::BettingsController < ApplicationController
  skip_before_action :verify_signature
  skip_before_action :verify_authenticity_token

  before_action :get_bet_type, only: [:create]


  def index

  end

  def create
    if params[:bet_num].to_i < 0 || ![1, 2].include?(@bet_type)
      Rails.logger.info("投注失败，非法操作，用户id#{current_user.id}，ip地址：#{request.remote_ip}" + e.to_s)
      return render json: {status: 500, msg: '投注失败，非法操作', data: {}}
    end
    if params[:bet_num].to_i > @bet_max_coin
      return render json: {status: 500, msg: '投注失败，超过最大投注限额', data: {}}
    end
    if ![10,100,500].include?(params[:bet_num].to_i)
      return render json: {status: 500, msg: '投注失败，非法数据', data: {}}
    end
    if (current_user.total_diamond_coin < params[:bet_num].to_i) && @bet_type != 2
      return render json: {status: 500, msg: '投注失败，钻石币数量不够', data: {}}
    end
    if @bet_type == 2 && $cache.get("give_chest_user#{current_user.id}").blank?
      return render json: {status: 500, msg: '投注失败，赠送已过期', data: {expired: 'expired'}}
    end
    if Betting.chance_left(current_user.id) <= 0 && @bet_type != 2
      return render json: {status: 500, msg: '投注失败，您今天的抽奖次数已用完', data: {}}
    end
    # bet_num = @bet_type == 0 ? [current_user.total_diamond_coin.to_i, 60].min : params[:bet_num].to_i

    return render json: Betting.generate_record!(params[:bet_num].to_i, current_user, @bet_type, request.ip)
  end

  # 分享
  def share_prize
    # @title = '分享宝箱中奖'
    # @betting = Betting.find_by(id: params[:id])
    # redirect_uri = CGI.escape("/home/share_open?share_user_id=#{current_user.id}")
    # @share_config = {
    #     title: "玩钻联模拟盘，赢百万好礼！",
    #     desc: "我在钻联中，获得了奖励，还能赢取百万好礼，你也来参加吧！",
    #     link_url: "#{SYSTEMCONFIG[:host]}/share?redirect_uri=#{redirect_uri}&share_user_id=#{current_user.id}&local_url=#{CGI.escape(request.url)}",
    #     img_url: "#{SYSTEMCONFIG[:host]}/default_image/share_rank.png",
    # }
  end

  private

  def chest_params
    params.require(:betting).permit(:bet_type, :request_ip)
  end

  # 确认是否新手
  def get_bet_type
    # @bet_type = current_user.is_fresh ? 0 : params[:bet_type].to_i
    @bet_type = params[:bet_type].to_i
    @bet_max_coin = $cache.fetch("bet_max_coin_now", 1 * 3600){
      Setting.bet_max_coin.blank? ? 500 : Setting.bet_max_coin.to_i
    }
  end

end
