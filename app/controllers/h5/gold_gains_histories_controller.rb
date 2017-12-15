class H5::GoldGainsHistoriesController < ApplicationController

  before_action :per_load, only: [:index, :rank_detail, :rank_rate_detail]
  before_action :generate_rank_data, only: [:index, :rank_detail, :rank_rate_detail]
  skip_before_filter :verify_authenticity_token

  layout 'login'

  def index
    @title = '竞赛'
    # GoldGainsHistory.generate_rank_data(current_user.id)

    # 收益排行
    @day_ranks = @day_rank_rates = JSON.parse($redis.get('day_datas'))

    @week_ranks = @week_rank_rates = JSON.parse($redis.get('week_datas'))

    @month_ranks = @month_rank_rates = JSON.parse($redis.get('month_datas'))

    @total_ranks = @total_rank_rates = JSON.parse($redis.get('total_datas'))

    @today_ranks = @today_rank_rates = JSON.parse($redis.get('today_datas'))
    self_rank
    self_rank_rate
    @friend_circle = PayTribute.current_week_gold_gain_rank current_user

    #邀請好友地址
    redirect_uri = CGI.escape("/home/share_open?share_user_id=#{current_user.id}")
    @share_config = {
        title: "玩钻联模拟盘，赢百万好礼！",
        desc: "您的好友#{current_user.nickname}邀请您参与钻联模拟盘竞赛并赠送您20,000元虚拟资金，可用于购买钻石，赚取收益",
        link_url: "#{SYSTEMCONFIG[:host]}/share?redirect_uri=#{redirect_uri}&share_user_id=#{current_user.id}&local_url=#{CGI.escape(request.url)}",
        img_url: "#{SYSTEMCONFIG[:host]}/default_image/share.png",
    }
    # render layout: "application"
  end

  # 收益明细
  def rank_detail
    @title = '收益排行'
    @type = params[:type]
    @day_ranks = JSON.parse($redis.get('day_datas')) rescue []
    @week_ranks = JSON.parse($redis.get('week_datas')) rescue []
    @month_ranks = JSON.parse($redis.get('month_datas')) rescue []
    @total_ranks = JSON.parse($redis.get('total_datas')) rescue []
    @today_ranks = JSON.parse($redis.get('today_datas')) rescue []
    self_rank
  end

  # 收益率明细
  def rank_rate_detail
    @title = '收益率排行'

    @type = params[:type]
    @day_rank_rates = JSON.parse($redis.get('day_datas')) rescue []
    @week_rank_rates = JSON.parse($redis.get('week_datas')) rescue []
    @month_rank_rates = JSON.parse($redis.get('month_datas')) rescue []
    @total_rank_rates = JSON.parse($redis.get('total_datas')) rescue []
    @today_rank_rates = JSON.parse($redis.get('today_datas')) rescue []
    self_rank_rate
  end

  # 当前用户所获得的收益排名
  def self_rank
    # 当前用户当天收益排名、是否可以领奖
    day_rank = $redis.get("self_rank_#{current_user.id}_day_rank") rescue nil
    @self_day_rank = day_rank.blank? ? nil : RankingConfig.gained_by(day_rank, 1, 1)

    week_rank = $redis.get("self_rank_#{current_user.id}_week_rank") rescue nil
    @self_week_rank = week_rank.blank? ? nil : RankingConfig.gained_by(week_rank, 2, 1)

    month_rank = $redis.get("self_rank_#{current_user.id}_month_rank") rescue nil
    @self_month_rank = month_rank.blank? ? nil : RankingConfig.gained_by(month_rank, 3, 1)

    total_rank = $redis.get("self_rank_#{current_user.id}_total_rank") rescue nil
    @self_total_rank = total_rank.blank? ? nil : RankingConfig.gained_by(total_rank, 4, 1)

    today_rank = $redis.get("self_rank_#{current_user.id}_today_rank") rescue nil
    @self_today_rank = today_rank.blank? ? nil : RankingConfig.gained_by(today_rank, 1, 1)
  end

  # 当前用户所获得的收益率排名
  def self_rank_rate
    # 当前用户当天收益率排名、是否可以领奖
    day_rank_rate = $redis.get("self_rank_#{current_user.id}_day_rank") rescue nil
    @self_day_rank_rate = day_rank_rate.blank? ? nil : RankingConfig.gained_by(day_rank_rate, 1, 2)

    week_rank_rate = $redis.get("self_rank_#{current_user.id}_week_rank") rescue nil
    @self_week_rank_rate = week_rank_rate.blank? ? nil : RankingConfig.gained_by(week_rank_rate, 2, 2)

    month_rank_rate = $redis.get("self_rank_#{current_user.id}_month_rank") rescue nil
    @self_month_rank_rate = month_rank_rate.blank? ? nil : RankingConfig.gained_by(month_rank_rate, 3, 2)

    total_rank_rate = $redis.get("self_rank_#{current_user.id}_total_rank") rescue nil
    @self_total_rank_rate = total_rank_rate.blank? ? nil : RankingConfig.gained_by(total_rank_rate, 4, 2)

    today_rank_rate = $redis.get("self_rank_#{current_user.id}_today_rank") rescue nil
    @self_today_rank_rate = today_rank_rate.blank? ? nil : RankingConfig.gained_by(today_rank_rate, 1, 2)
  end

  # 获取奖励
  def get_gain
    begin
      res = {}
      ActiveRecord::Base.transaction do
        ranking_config_win = RankingConfigWin.get_gain!(current_user, params[:ranking_config_id], request.remote_ip)
        if ranking_config_win && !params[:address].blank?
          address = Address.create!(params[:address].as_json.merge(user_id: current_user.id))
          ranking_config_win.ranking_config_win_orders.update_all(address_id: address.id, status: 0)
        end
        res = {status: 200, msg: '领取成功！', data: ranking_config_win.id}
      end
    rescue Exception => e
      Rails.logger.info(e)
      res = {status: 500, msg: '领取失败！'}
    end
    return render json: res
  end

  def currency_description
    @title = '竞赛规则'
  end

  def share_prize
    @title = '领取奖励'
    @ranking_config = RankingConfig.where("id = ?", params[:rc]).first
    redirect_uri = CGI.escape("/home/share_open?share_user_id=#{current_user.id}")
    @share_config = {
        title: "玩钻联模拟盘，赢百万好礼！",
        desc: "我在钻联模拟盘竞赛中，获得了奖励，还能赢取百万好礼，你也来参加吧！",
        link_url: "#{SYSTEMCONFIG[:host]}/share?redirect_uri=#{redirect_uri}&share_user_id=#{current_user.id}&local_url=#{CGI.escape(request.url)}",
        img_url: "#{SYSTEMCONFIG[:host]}/default_image/share_rank.png",
    }
  end

  #朋友圈进贡记录
  def friend_circle_record
    @title = "我的记录"

    @pay_tributes = $cache.fetch("pay_tributes_c#{current_user.id}",60*5) {

      pts = current_user.pay_tributes.includes(:tribute_user).all.order('created_at desc')
      pts_arr = []
      pts.each do |pt|
        pts_arr << {user_id: pt.tribute_user.id, nickname: pt.tribute_user.nickname, phone: pt.tribute_user.phone,
                    headimgurl: pt.tribute_user.headimgurl,tribute_type: pt.tribute_type,amount: pt.amount,created_at: pt.created_at}
      end
      pts_arr
    }


  end

  #领取奖品 填写收货地址
  def receive_prizes
    @title = "领取奖品"
    # @ranking_config = RankingConfig.where("id = ?", params[:rc]).first
    @ranking_config_id = params[:rc]
  end

  private
  def per_load
    @d = Date.today
    @gold = SYSTEMCONFIG[:admin_config][:user_register][:gold]
  end

  def generate_rank_data
    GoldGainsHistory.generate_rank_data(current_user.id)
  end

end
