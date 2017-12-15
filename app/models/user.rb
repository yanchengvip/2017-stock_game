#role用户角色 1:普通用户,2:管理员,3:内测用户
#status用户状态 -1:冻结,0:正常(未充值),1:已激活(已充值)
class User < ApplicationRecord

  action_store :follow, :user, counter_cache: 'followers_count', user_counter_cache: 'following_count'
  has_many :hold_diamonds, -> { where status: [0, 1] }
  has_many :diamond_trades
  has_many :booking_trades, -> { where(status: [0, -1]) }
  has_many :roles
  has_many :addresses,-> {where(status: 0)}
  has_many :gold_gains_histories
  has_many :lottery_orders
  has_many :gold_accounts
  has_many :diamond_accounts
  has_many :ranking_config_wins
  has_many :ranking_config_win_orders
  has_many :lottery_order_items
  has_many :exchange_coins
  has_many :gold_gains_weeks
  has_many :gold_gains_months
  has_many :trade_boxs
  has_many :share_users, class_name: 'User', foreign_key: 'share_user_id'
  belongs_to :parent_user,class_name: 'User',foreign_key: 'share_user_id'
  has_many :user_login_logs
  has_many :lottery_order_win_items, -> { where(is_win: true) }, class_name: 'LotteryOrderItem', foreign_key: 'user_id'
  has_many :coin_bag_lottery_items
  has_many :coin_bag_lotteries
  has_many :lotteries
  has_many :csv_files
  has_many :pay_tributes
  has_many :micro_diamond_accounts
  validates :total_gold, numericality: {greater_than_or_equal_to: 0}
  validates :available_gold, numericality: {greater_than_or_equal_to: 0}
  #validates :total_diamond_coin, numericality: {greater_than_or_equal_to: 0} #进贡钻石币可为负值
  validates :phone, uniqueness: true, allow_nil: true
  before_create :generate_authentication_token

  include Admins::SearchHelper
  include Admins::DownloadCsv
  include Admins::CsvDataHelper
  include Admins::Users::UserBalanceHelper
  include Admins::Users::WeixinHelper
  include Admins::Users::UsersSubscribeHelper
  # user.follow_by_users 关注自己的用户列表
  # user.follow_users 自己关注的用户列表
  # user.create_action(:follow, target: user2) user1 -> follow user2
  #user.followers_count 关注自己的人数
  #user.following_count 自己关注的人数

  # mount_uploader :headimgurl,   ImageUploader

  self.xml_options = {
      :only => ["id", "phone",  "province", "openid", "nickname", "sex", "city", "country", "headimgurl", "unionid", "created_at", "updated_at",  "following_count", "followers_count", "total_gold", "available_gold", "hold_diamonds_count", "total_gold_gains", "total_diamond_coin", "share_user_id", "request_ip", "subscribe_status", "accept_agreement", "status", "share_user_gived", "is_fresh", "authentication_token", "authentication_token_expire_time"].freeze,
  }

  def self.find_user_id_by_authentication_token(authentication_token)
    $cache.fetch("authentication_token_#{authentication_token}", 60 * 10){
      user =  User.where(authentication_token: authentication_token).first
      if user && user.authentication_token_expire_time > Time.now
        user.id
      else
        nil
      end
    }
  end

  #生成用户auth token
  def generate_authentication_token
    loop do
      self.authentication_token = SecureRandom.base64(64)
      break if !User.find_by(authentication_token: authentication_token)
    end
  end

  #存储用户的token
  def reset_auth_token!
    $cache.delete("authentication_token_#{self.authentication_token}")
    generate_authentication_token
    self.authentication_token_expire_time = Time.now + SYSTEMCONFIG[:authentication_token_expire_time]
    save
  end


  #计算所有用户的 天 收益
  def self.cal_gold_gains(day = Date.today)
    close_diamonds_price = Dialink::DiamondPriceHistory.all_diamonds_his_price(day.at_end_of_day.strftime("%Y-%m-%d %H:%M:%S"))
    yesterday_close_diamonds_price = Dialink::DiamondPriceHistory.all_diamonds_his_price((day-1).at_end_of_day.strftime("%Y-%m-%d %H:%M:%S"))
    User.all.each do |user|
      if user.created_at < day.at_end_of_day
        user.cal_gold_gains(close_diamonds_price, yesterday_close_diamonds_price, day)
      end
    end
  end

  #用户总资产
  def total_assets
    hold_diamonds = HoldDiamond.hold_diamonds_info(self.id)
    sale_diamonds_price =SaleDiamond.current_prices
    self.total_gold + hold_diamonds.inject(0) { |sum, kv| sum += sale_diamonds_price[kv[0]] * kv[1] } + DiamondTrade.where(close_shorting_status: [0, 1], user_id: self.id, bussiness_type: 3).inject(0) { |sum, x| sum += (2 * x.price - sale_diamonds_price[x.sale_diamond_id]) * x.total_count }
 end

  def headimgurl
    self.attributes["headimgurl"].presence || SYSTEMCONFIG[:user_default_headimgurl]
  end

  #计算自己 的 day 收益
  def cal_gold_gains close_diamonds_price, yesterday_close_diamonds_price, day
    hold_diamonds_gains = cal_hold_diamonds_gains(close_diamonds_price, yesterday_close_diamonds_price, day)
    trade_diamonds_gains = cal_current_day_trade_diamonds_gains(close_diamonds_price, yesterday_close_diamonds_price, day)
    close_gains = cal_close_gains(close_diamonds_price, yesterday_close_diamonds_price, day)
    short_gains = cal_short_gains(close_diamonds_price, yesterday_close_diamonds_price, day)

    self.gold_gains_histories.create(amount: hold_diamonds_gains + trade_diamonds_gains + close_gains + short_gains, day: day.to_s, hold_diamonds_gains: hold_diamonds_gains, trade_diamonds_gains: trade_diamonds_gains, close_gains: close_gains, short_gains: short_gains)
    self.update(total_gold_gains: self.gold_gains_histories.sum(:amount))
  end

  #计算持有钻石收益
  def cal_hold_diamonds_gains close_diamonds_price, yesterday_close_diamonds_price, day
    self.hold_diamonds.where("created_at < ?", day.at_end_of_day).inject(0) { |sum, hold_diamond| sum +=
        (hold_diamond.buy_time > day.beginning_of_day ? (close_diamonds_price[hold_diamond.sale_diamond_id] - hold_diamond.buy_price) : (close_diamonds_price[hold_diamond.sale_diamond_id] - yesterday_close_diamonds_price[hold_diamond.sale_diamond_id])) }
  end

  #计算当天出售钻石收益
  def cal_current_day_trade_diamonds_gains close_diamonds_price, yesterday_close_diamonds_price, day
    HoldDiamond.where("user_id = #{self.id} and sell_time <= ? and sell_time >= ? and status = 2", day.at_end_of_day.strftime("%Y-%m-%d %H:%M:%S"), day.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")).inject(0) { |sum, hold_diamond| sum += (hold_diamond.buy_time > day.beginning_of_day ? (hold_diamond.sell_price - hold_diamond.buy_price) : (hold_diamond.sell_price - yesterday_close_diamonds_price[hold_diamond.sale_diamond_id])) }
  end

  #当天平仓收益
  def cal_close_gains close_diamonds_price, yesterday_close_diamonds_price, day
    res = 0
    self.diamond_trades.where(bussiness_type: 4).where("created_at >= '#{day.beginning_of_day}' and created_at <= '#{day.at_end_of_day}'").each do |diamond_trade|
      short_diamond_trade = DiamondTrade.find(diamond_trade.booking_trade.diamond_trade_id)
      if short_diamond_trade.created_at >= day.beginning_of_day
        res += -(diamond_trade.total_price - short_diamond_trade.total_price)
      else
        res += -(diamond_trade.total_price - yesterday_close_diamonds_price[diamond_trade.sale_diamond_id] * diamond_trade.total_count)
      end
    end
    return res
  end

  #做空收益
  def cal_short_gains close_diamonds_price, yesterday_close_diamonds_price, day
    res = 0
    self.diamond_trades.where("created_at < ?", day.at_end_of_day).where(bussiness_type: 3, close_shorting_status: [0, 1]).each do |diamond_trade|

      if diamond_trade.created_at >= day.beginning_of_day
        res += -(close_diamonds_price[diamond_trade.sale_diamond_id] * diamond_trade.total_count - diamond_trade.total_price)
      else
        res += -((close_diamonds_price[diamond_trade.sale_diamond_id] - yesterday_close_diamonds_price[diamond_trade.sale_diamond_id])* diamond_trade.total_count)
      end
    end
    return res
  end


  #初始化模拟盘用户数据
  def init_diamond_info
    BookingTrade.where(user_id: self.id).destroy_all
    DiamondTrade.where(user_id: self.id).destroy_all
    HoldDiamond.where(user_id: self.id).destroy_all
    self.gold_accounts.destroy_all
    self.diamond_accounts.destroy_all
    self.update(total_gold: 20000, available_gold: 20000, hold_diamonds_count: 0)
    # User.reset_counters(self.id, :hold_diamonds)
    $cache.flush_all
  end

  #用户登录
  def self.login(phone, password)
    user = User.where(phone: phone).first
    if user
      if Digest::SHA1.hexdigest(password+user.salt) == user.encrypted_password
        return user
      else
        return nil
      end
    else
      return nil
    end
  end

  def avatar_url
    avata = headimgurl || 'h5/images/头像@2x.png'
  end

  before_create :encrypt_password
  #更改用户密码
  def encrypt_password
    if encrypted_password
      self.salt = (('a'..'z').to_a+(0..9).to_a+('A'..'Z').to_a).sample(32).join("")
      self.encrypted_password = Digest::SHA1.hexdigest(self.encrypted_password+self.salt)
    end
  end

  before_update :check_password_change
  #更改用户密码
  def check_password_change
    if self.encrypted_password_change
      self.salt = (('a'..'z').to_a+(0..9).to_a+('A'..'Z').to_a).sample(32).join("") if self.salt.nil?
      self.encrypted_password = Digest::SHA1.hexdigest(self.encrypted_password+self.salt)
    end
  end


  # 获取用户总收益排行
  def self.rank_data(num, user_id)
    if $redis.get('total_datas').blank?
      datas = User.select("id, total_gold_gains, headimgurl, nickname, phone").order(total_gold_gains: :desc, created_at: :desc).limit(num)
      $redis.set('total_datas', datas.to_json, :ex => 1800)
    end

    if $redis.get("self_rank_#{user_id}_total_data").blank?
      self_data = where(id: user_id).first
      rank = User.select("id, total_gold_gains, headimgurl, nickname, phone").order(total_gold_gains: :desc, created_at: :desc).map(&:id).index(user_id) + 1 rescue nil
      $redis.set("self_rank_#{user_id}_total_data", self_data.to_json, :ex => 300)
      $redis.set("self_rank_#{user_id}_total_rank", rank, :ex => 300)
    end
  end

  # 用户是否领取过某个奖项
  def gained?(ranking_config)
    d = Date.today
    # mday = d.mday
    year = d.year
    # week = d.cweek
    # if d.beginning_of_week == d && ("#{d} 17:30:00".to_time - Time.now).to_i > 0
    #   week = d.cweek - 1
    # end
    # month = d.month
    # if d.beginning_of_month == d && ("#{d} 17:30:00".to_time - Time.now).to_i > 0
    #   month = d.month - 1
    # end
    if ranking_config.date_type != 4
      ranking_config_wins = ranking_config.ranking_config_wins.where(user_id: self.id, year: year)
    else
      ranking_config_wins = ranking_config.ranking_config_wins.where(user_id: self.id)
    end
    gained = ranking_config_wins.blank? ? false : RankingConfig.check_date(ranking_config_wins, ranking_config.date_type, ranking_config.id)

    return gained
  end

  # 邀请的用户
  def invited_users
    DiamondAccount.where(diamond_type: DiamondAccount::DIAMONDTYPE["邀请注册赠送"], user_id: self.id).includes(:follower_user)
  end

  # 邀请某用户所获得的奖励
  def gold_gain_from_invite(user_id)
    gold_accounts.where(table_id: user_id, table_type: "User", account_type: GoldAccount::ACCOUNTTYPE["邀请注册"]).first
  end

  # 用户兑换钻石币
  def g_exchange_coins!(coin_num, gold_num)
    # res = nil
    ActiveRecord::Base.transaction do
      res = self.exchange_coins.create!(diamond_exchange_rate: SYSTEMCONFIG[:admin_config][:diamond_exchange_rate], num: coin_num,
                                        gold_amount: gold_num, day: Date.today)
    end

    # return res.blank? ? false : true
  end

  # 用户今天剩余的可兑换钻石币数量，最多2000
  def left_exc_coin_num_today
    max = SYSTEMCONFIG[:admin_config][:exchange][:day_limit]
    has_exchanged = ExchangeCoin.where(user_id: self.id, day: Date.today).sum("num")
    can_exchange = (max - has_exchanged) <= 0 ? 0 : (max - has_exchanged)

    useful_gold = self.available_gold - SYSTEMCONFIG[:admin_config][:user_register][:gold]
    coin_num = useful_gold <= 0 ? 0 : (useful_gold / SYSTEMCONFIG[:admin_config][:diamond_exchange_rate]).to_i

    return {can_exchange: [can_exchange, coin_num].min, has_exchanged: has_exchanged}
  end

  def day_signed?
    day = Date.today
    signed = $cache.fetch("day_signed_day#{day}_user#{self.id}", 1 * 3600){
      DaySign.find_by(user_id: self.id, day: day)
    }
    return signed.blank? ? false : true
  end


  after_create :check_share_user
  after_create :give_diamond_account
  private
  def check_share_user
    if self.share_user_id && share_user = User.where(id: self.share_user_id).first
      User.transaction do
        invite_count = User.where(share_user_id: self.share_user_id).lock.count
        unless invite_count >= SYSTEMCONFIG[:admin_config][:invite_user_each][:limit_count]
          if SYSTEMCONFIG[:admin_config][:invite_user_each][:gold] && SYSTEMCONFIG[:admin_config][:invite_user_each][:gold] > 0
            GoldAccount.create!(user_id: self.share_user_id, amount: SYSTEMCONFIG[:admin_config][:invite_user_each][:gold], account_type: GoldAccount::ACCOUNTTYPE["邀请注册"], table_type: "User", table_id: self.id, available_gold_amount: SYSTEMCONFIG[:admin_config][:invite_user_each][:gold])
          end

          if SYSTEMCONFIG[:admin_config][:invite_user_each][:diamond_account] && SYSTEMCONFIG[:admin_config][:invite_user_each][:diamond_account] > 0
            DiamondAccount.create!(user_id: self.share_user_id, amount: SYSTEMCONFIG[:admin_config][:invite_user_each][:diamond_account], diamond_type: DiamondAccount::DIAMONDTYPE["邀请注册赠送"], table_type: "User", table_id: self.id)
          end
        end
      end

      #清空朋友圈缓存
      PayTribute.clear_friend_circle share_user
    end
  end

  def give_diamond_account
    if SYSTEMCONFIG[:admin_config] && SYSTEMCONFIG[:admin_config][:user_register] && SYSTEMCONFIG[:admin_config][:user_register][:diamond_account].to_i > 0
      DiamondAccount.create!(user_id: self.id, amount: SYSTEMCONFIG[:admin_config][:user_register][:diamond_account], diamond_type: DiamondAccount::DIAMONDTYPE["注册赠送"])
    end
  end


end
