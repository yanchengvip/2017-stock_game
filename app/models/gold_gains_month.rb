# 月收益排名数据表
class GoldGainsMonth < ApplicationRecord

  belongs_to :user

  self.xml_options = {
    :only => [:id, :user_id, :amount, :month, :year, :created_at, :updated_at].freeze,
    :include => {
      :user => { :only => ["id", "phone", "nickname", "headimgurl"] }
    }
  }

  def self.rank_data(num, user_id)
    d = Date.today
    month = d.month
    if d.beginning_of_month == d && ("#{d} 17:30:00".to_time - Time.now).to_i > 0
      month = d.month - 1
    end
    year = d.year

    if $redis.get('month_datas').blank?
      # datas = where(year: year, month: month).order(amount: :desc, created_at: :desc).limit(num).includes(:user)
      datas = select("g.id,g.user_id, g.amount, g.month,g.year,users.id,users.created_at").joins("as g left join users on users.id=g.user_id").where("g.year='#{year}' and g.month='#{month}'").order("g.amount desc, users.created_at desc").limit(num)
      $redis.set('month_datas', datas.as_json.to_json, :ex => 1800)
    end

    if $redis.get("self_rank_#{user_id}_month_data").blank?
      self_data = where(year: year, month: month, user_id: user_id).includes(:user).first
      # rank = GoldGainsMonth.where(year: year, month: month).order(amount: :desc, created_at: :asc).where("amount > ?", self_data.amount).size + 1 rescue nil
      # rank = GoldGainsMonth.where(year: year, month: month).order(amount: :desc, created_at: :desc).map(&:user_id).index(user_id) + 1 rescue nil
      rank = GoldGainsMonth.select("g.id,g.user_id, g.amount, g.month,g.year,users.id,users.created_at").joins("as g left join users on users.id=g.user_id").where("g.year='#{year}' and g.month='#{month}'").order("g.amount desc, users.created_at desc").map(&:user_id).index(user_id) + 1 rescue nil
      $redis.set("self_rank_#{user_id}_month_data", self_data.as_json.to_json, :ex => 300)
      $redis.set("self_rank_#{user_id}_month_rank", rank, :ex => 300)
    end
  end
end
