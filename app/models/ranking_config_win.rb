# 奖励领取记录表
class RankingConfigWin < ApplicationRecord
  belongs_to :ranking_config
  belongs_to :user
  has_many :ranking_config_win_orders
  has_one :lottery
  has_many :ranking_config_items,through: :ranking_config
  has_many :gold_accounts,as: :table
  delegate :ranking_configs,to: :ranking_config

  validates_uniqueness_of :user_id, scope: [:ranking_config_id, :year, :week, :rank_type, :date_type, :day]


  after_create :generate_datas

  def self.get_gain!(user, ranking_config_id, ip)
    d = Date.today
    year = d.year
    week = d.cweek
    if d.beginning_of_week == d && ("#{d} 17:30:00".to_time - Time.now).to_i > 0
      week = d.cweek - 1
    end
    month = d.month
    if d.beginning_of_month == d && ("#{d} 17:30:00".to_time - Time.now).to_i > 0
      month = d.month - 1
    end
    ranking_config = RankingConfig.find(ranking_config_id)
    date_type = ranking_config.date_type
    if ranking_config.date_type == 1 && ("#{d} 17:30:00".to_time - Time.now).to_i < 0
      date_type = 5
    end
    
    win = user.ranking_config_wins.create!(ranking_config_id: ranking_config_id, lottery_time: Time.now, request_ip: ip, year: year,
                                                                    month: month, week: week, date_type: date_type, rank_type: ranking_config.ranking_type,
                                                                    day: d)
  end

  private
  # 生成领取奖励记录同时创建相关订单数据
  def generate_datas
    ranking_config = self.ranking_config
    items = ranking_config.ranking_config_items
    items.each do |item|
      item.generate_orders!(self)
    end
  end

end
