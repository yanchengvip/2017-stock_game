# 周收益排名表
class GoldGainsWeek < ApplicationRecord

  belongs_to :user

  self.xml_options = {
    :only => [:id, :user_id, :amount, :week, :year, :created_at, :updated_at].freeze,
    :include => {
      :user => { :only => ["id", "phone", "nickname", "headimgurl"] }
    }
  }

  def self.rank_data(num, user_id)
    d = Date.today
    week = d.cweek

    if d.beginning_of_week == d && ("#{d} 17:30:00".to_time - Time.now).to_i > 0
      week = d.cweek - 1
    end
    year = d.year

    if $redis.get('week_datas').blank?
      # datas = where(year: year, week: week).order(amount: :desc, created_at: :desc).limit(num).includes(:user)
      datas = select("g.id,g.user_id, g.amount, g.week,g.year,users.id,users.created_at").joins("as g left join users on users.id=g.user_id").where("g.year='#{year}' and g.week='#{week}'").order("g.amount desc, users.created_at desc").limit(num)
      $redis.set('week_datas', datas.as_json.to_json, :ex => 1800)
    end

    if $redis.get("self_rank_#{user_id}_week_data").blank?
      self_data = where(year: year, week: week, user_id: user_id).includes(:user).first
      # rank = GoldGainsWeek.where(year: year, week: week).order(amount: :desc, created_at: :asc).where("amount > ?", self_data.amount).size + 1 rescue nil
      # rank = GoldGainsWeek.where(year: year, week: week).order(amount: :desc, created_at: :desc).map(&:user_id).index(user_id) + 1 rescue nil
      rank = GoldGainsWeek.select("g.id,g.user_id, g.amount, g.week,g.year,users.id,users.created_at").joins("as g left join users on users.id=g.user_id").where("g.year='#{year}' and g.week='#{week}'").order("g.amount desc, users.created_at desc").map(&:user_id).index(user_id) + 1 rescue nil
      $redis.set("self_rank_#{user_id}_week_data", self_data.as_json.to_json, :ex => 300)
      $redis.set("self_rank_#{user_id}_week_rank", rank, :ex => 300)
    end
  end

end
