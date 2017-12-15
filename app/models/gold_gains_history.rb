class GoldGainsHistory < ApplicationRecord
  belongs_to :user
  self.xml_options = {
    :only => [:id, :user_id, :amount, :day, :created_at, :updated_at].freeze,
    :include => {
      :user => { :only => ["id", "phone", "nickname", "headimgurl"] }
    }
  }
  def self.init
    (Date.parse("2017-03-01")..Date.yesterday).each do |day|
      User.cal_gold_gains(day)
    end
  end

  # 生成周收益数据
  def self.generate_week_data
    d = Date.today
    week_ranks  = GoldGainsHistory.where(day: d.beginning_of_week..(d.end_of_week - 1)).select("user_id, sum(amount) as total").group('user_id').order("sum(amount) desc")
    week = d.cweek
    year = d.year
    week_ranks.each do |wr|
      ggw = GoldGainsWeek.find_or_initialize_by(user_id: wr.user_id, week: week, year: year)
      ggw.update(amount: wr.total)
    end
  end

  # 生成月收益数据
  def self.generate_month_data
    d = Date.today
    month_ranks  = GoldGainsHistory.where(day: d.at_beginning_of_month..d.end_of_month).select("user_id, sum(amount) as total").group('user_id').order("sum(amount) desc")
    month = d.month
    year = d.year
    month_ranks.each do |mr|
      ggm = GoldGainsMonth.find_or_initialize_by(user_id: mr.user_id, month: month, year: year)
      ggm.update(amount: mr.total)
    end
  end

  # 昨日收益排行
  def self.day_ranks(num, user_id)
    if $redis.get('day_datas').blank?
      # datas = select("id,user_id, amount").where(day: (Date.today - 1).to_s).order(amount: :desc, created_at: :desc).limit(num).includes(:user)
      datas = select("g.id,g.user_id, g.amount, g.day,users.id,users.created_at").joins("as g left join users on users.id=g.user_id").where("g.day = '#{(Date.today - 1).to_s}'").order("g.amount desc, users.created_at desc").limit(num)
      # .includes(:user)
      $redis.set('day_datas', datas.as_json.to_json, :ex => 1800)
    end
    # 当前用户当tian收益排名、是否可以领奖
    if $redis.get("self_rank_#{user_id}_day_data").blank?
      self_data = select("id,user_id, amount").where(user_id: user_id, day: (Date.today - 1).to_s).includes(:user).first
      # rank = GoldGainsHistory.select("id,user_id, amount").where(day: (Date.today - 1).to_s).order(amount: :desc, created_at: :asc).where("amount > ?", self_data.amount).size + 1 rescue nil
      rank = GoldGainsHistory.select("g.id,g.user_id, g.amount, g.day,users.id,users.created_at").joins("as g left join users on users.id=g.user_id").where("g.day = '#{(Date.today - 1).to_s}'").order("g.amount desc, users.created_at desc").map(&:user_id).index(user_id) + 1 rescue nil
      $redis.set("self_rank_#{user_id}_day_data", self_data.as_json.to_json, :ex => 300)
      $redis.set("self_rank_#{user_id}_day_rank", rank, :ex => 300)
    end
  end

  # 今日收益排行
  def self.today_ranks(num, user_id)
    if $redis.get('today_datas').blank?
      # datas = select("id,user_id, amount").where(day: Date.today.to_s).order(amount: :desc, created_at: :desc).limit(num).includes(:user)
      datas = select("g.id,g.user_id, g.amount, g.day,users.id,users.created_at").joins("as g left join users on users.id=g.user_id").where("g.day = '#{Date.today.to_s}'").order("g.amount desc, users.created_at desc").limit(num)
      $redis.set('today_datas', datas.as_json.to_json, :ex => 1800)
    end

    if $redis.get("self_rank_#{user_id}_today_data").blank?
      self_data = select("id,user_id, amount").where(user_id: user_id, day: Date.today.to_s).includes(:user).first
      # rank = GoldGainsHistory.select("id,user_id, amount").where(day: Date.today.to_s).order(amount: :desc, created_at: :asc).where("amount > ?", self_data.amount).size + 1 rescue nil
      # rank = GoldGainsHistory.select("id,user_id, amount").where(day: Date.today.to_s).order(amount: :desc, created_at: :desc).map(&:user_id).index(user_id) + 1 rescue nil
      rank = GoldGainsHistory.select("g.id,g.user_id, g.amount, g.day,users.id,users.created_at").joins("as g left join users on users.id=g.user_id").where("g.day = '#{Date.today.to_s}'").order("g.amount desc, users.created_at desc").map(&:user_id).index(user_id) + 1 rescue nil
      $redis.set("self_rank_#{user_id}_today_data", self_data.as_json.to_json, :ex => 300)
      $redis.set("self_rank_#{user_id}_today_rank", rank, :ex => 300)
      # $redis.expire("self_rank_#{user_id}_today_rank", 30.minutes.to_i)
    end
  end

  # 生成用户排名数据，所有其他排名数据
  def self.generate_rank_data(user_id)
    GoldGainsHistory.day_ranks(10, user_id)
    GoldGainsHistory.today_ranks(10, user_id)
    GoldGainsWeek.rank_data(10, user_id)
    GoldGainsMonth.rank_data(10, user_id)
    User.rank_data(10, user_id)
  end

  # 晴空缓存
  def self.refresh_redis_datas
    $redis.expire("day_datas", 1)
    $redis.expire("today_datas", 1)
    $redis.expire("week_datas", 1)
    $redis.expire("month_datas", 1)
    $redis.expire("total_datas", 1)
  end

  # 用户修改信息（头像）
  def self.refresh_user_datas(user_id)
    $redis.expire("day_datas", 1)
    $redis.expire("today_datas", 1)
    $redis.expire("week_datas", 1)
    $redis.expire("month_datas", 1)
    $redis.expire("total_datas", 1)
    $redis.expire("self_rank_#{user_id}_day_data", 1)
    $redis.expire("self_rank_#{user_id}_today_data", 1)
    $redis.expire("self_rank_#{user_id}_total_data", 1)
    $redis.expire("self_rank_#{user_id}_week_data", 1)
    $redis.expire("self_rank_#{user_id}_month_data", 1)
  end

end
