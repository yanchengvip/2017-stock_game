class RankingConfig < ApplicationRecord
  has_many :ranking_config_items,dependent: :destroy
  has_many :ranking_config_wins,dependent: :destroy
  include Admins::RankingConfigHelper

  DATETYPE = {
    0 => "无分配",
    100 => "系统赠送",
    1 => "日排行奖励",
    2 => "周排行奖励",
    3 => "月排行奖励",
    4 => "总排行奖励",
  }
  # 某用户是否中奖
  # ranking,default: 0,comment: '名次:1..10'
  # date_type,default: 0,comment: '无分配:0,日:1, 周:2,  月:3, 总:4'
  # ranking_type,default: 0,comment: '0:无分类,1:收益,2:收益率'
  def self.gained_by(ranking, date_type, ranking_type)
    return nil if ranking.blank?
    ranking_config = $cache.fetch("gained_by_#{ranking}_#{date_type}_#{ranking_type}", 60){
      RankingConfig.find_by(ranking: ranking, date_type: date_type, ranking_type: ranking_type, status: 1)
    }
    ranking_config
  end

  def self.get_rank(user)
    day_rank = $redis.get("self_rank_#{user.id}_day_rank") rescue nil
    week_rank = $redis.get("self_rank_#{user.id}_week_rank") rescue nil
    month_rank = $redis.get("self_rank_#{user.id}_month_rank") rescue nil
    total_rank = $redis.get("self_rank_#{user.id}_total_rank") rescue nil
    today_rank = $redis.get("self_rank_#{user.id}_today_rank") rescue nil
    arr = [[day_rank, 1], [week_rank, 2], [month_rank, 3], [total_rank, 4], [today_rank, 5]]
  end

  # 检查是否中奖
  def self.check_rank(user)
    # arr = [[day_rank, 1], [week_rank, 2], [month_rank, 3], [total_rank, 4], [today_rank, 5]] #5表示今天
    arr = RankingConfig.get_rank(user)
    year = Date.today.year
    
    res = arr.map do |type|
      can_get = can_get_rate = true
      if type[0].present? # 该类型排名
        can_get = can_get_rate = false if type[1] == 1 && ("#{Date.today} 17:30:00".to_time - Time.now).to_i <= 0
        can_get = can_get_rate = false if type[1] == 2 && ("#{Date.today.end_of_week - 1} 17:30:00".to_time - Time.now).to_i > 0
        can_get = can_get_rate = false if type[1] == 3 && ("#{Date.today.end_of_month} 17:30:00".to_time - Time.now).to_i > 0
        can_get = can_get_rate = false if type[1] == 4
        # type_tmp = 1 if type[1] == 5
        if (can_get && can_get_rate)
          if type[1] == 5
            ranking_config = RankingConfig.gained_by(type[0], 1, 1) #该收益排名配置
            ranking_config_rate = RankingConfig.gained_by(type[0], 1, 2) #该收益率排名配置
          else
            ranking_config = RankingConfig.gained_by(type[0], type[1], 1) #该收益排名配置
            ranking_config_rate = RankingConfig.gained_by(type[0], type[1], 2) #该收益率排名配置
          end

          # 是否领取过
          if ranking_config # 该周期收益获奖
            ranking_config_wins = ranking_config.ranking_config_wins.where(user_id: user.id)
            # true 获奖但未领取; 该周期该用户所有领奖记录
            can_get = ranking_config_wins.blank? ? true : !RankingConfig.check_date(ranking_config_wins, type[1], ranking_config.id)
          else
            can_get = false
          end
          if ranking_config_rate # 该周期收益获奖
            ranking_config_wins = ranking_config_rate.ranking_config_wins.where(user_id: user.id)
            # true 获奖但未领取, 该周期改用户所有领奖记录
            can_get_rate = ranking_config_wins.blank? ? true : !RankingConfig.check_date(ranking_config_wins, type[1], ranking_config.id)
          else
            can_get_rate = false
          end
        end
      else
        can_get = can_get_rate = false
      end
      [can_get, can_get_rate]
    end.flatten.compact

    return res.include?(true)
  end

  # 某周期是否领奖，返回 true，false
  def self.check_date(ranking_config_wins, date_type, ranking_config_id)
    d = Date.today
    week = d.cweek
    year = d.year
    if d.beginning_of_week == d && ("#{d} 17:30:00".to_time - Time.now).to_i > 0
      week = d.cweek - 1
    end
    month = d.month
    if d.beginning_of_month == d && ("#{d} 17:30:00".to_time - Time.now).to_i > 0
      month = d.month - 1
    end

    got = nil
    # ranking_config_wins = ranking_config_wins.where("YEAR(created_at)=?", year) if date_type != 4 #不是总排名
    ranking_config_wins.each do |ranking_config_win|
      record_time = ranking_config_win.created_at
      record_day = record_time.to_date
      case date_type
      when 1
        if ("#{d} 17:30:00".to_time - Time.now).to_i < 0
          got = (record_day == d && record_time > "#{d} 17:30:00".to_time)
        else
          # got = (record_day == (d - 1) && record_time < "#{d} 17:30:00".to_time) || (record_day == d && record_time < "#{d} 17:30:00".to_time)
          got = (record_day == (d - 1) || record_day == d) && record_time < "#{d} 17:30:00".to_time
        end
      when 2
        got = (week == ranking_config_win.week)
      when 3
        got = (month == ranking_config_win.month)
      when 4
        # 暂时不能领取总排名奖
        got =true
      when 5
        got = (record_day == d && record_time > "#{d} 17:30:00".to_time)
      end
      break if got
    end
    got
  end

end
