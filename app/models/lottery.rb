class Lottery < ApplicationRecord
  #:status 0 初始 -1 取消 1 待开奖 2 已开奖
  #auto_extension_status是否自动延续下一期:  1:不自动延续,2:自动延续,3:已经完成自动延续
  validates_numericality_of :total_count, greater_than: 0
  validates :lottery_percent, numericality: {greater_than: 0, less_than_or_equal_to: 1}
  # validates :lottery_code, uniqueness: true, allow_nil: true
  # validates_uniqueness_of :product_id, scope: [:published_at]
  has_many :lottery_orders, dependent: :destroy
  has_one  :lottery_order,->{where(is_win: true)}
  has_many :lottery_order_items, dependent: :destroy
  has_many :diamond_accounts, as: :table
  belongs_to :product
  belongs_to :user
  belongs_to :win_user, class_name: "User", foreign_key: "win_user_id"
  delegate :products, :to => :product
  include Admins::SearchHelper
  include Admins::LotteryHelper
  after_create :generate_code
  after_create :generate_product_type
  before_save :default_end_time
  after_create :reduce_inventory_count
  class_attribute :buy_record_xml_options

  self.xml_options = {
      :only => ["id", "product_id", "published_at", "product_name", "sales_count", "total_count", "price", "status", "lottery_time", "created_at", "updated_at", "sort", "award", "lottery_code", "end_time", "user_id", "win_user_id", "win_lottery_code", "num_a", "num_b", "take_award", "product_type", "win_share", "participant_time",
                "progress", "lottery_end_time", "auto_extension_status", "auto_extension_start_time", "auto_extension_end_time",
                "auto_extension_interval"].freeze,
      :include => {
          :product => {:only => ["id", "name", "desc", "price", "inventory_count", "detail_url", "head_image", "is_published", "user_id", "created_at", "updated_at", "product_type", "award", "total_count", "end_time"]},
          :win_user => {:only => ["id", "phone", "nickname", "headimgurl"]},
      }
  }

  self.buy_record_xml_options = {
      :only => ["id", "product_id", "published_at", "product_name", "sales_count", "total_count", "price", "status", "lottery_time", "created_at", "updated_at", "sort", "award", "lottery_code", "end_time", "user_id", "win_user_id", "win_lottery_code", "num_a", "num_b", "take_award", "product_type", "win_share", "participant_time",
                "progress", "lottery_end_time", "auto_extension_status", "auto_extension_start_time", "auto_extension_end_time",
                "auto_extension_interval"].freeze,
      :include => {
          :product => {:only => ["id", "name", "desc", "price", "inventory_count", "detail_url", "head_image", "is_published", "user_id", "created_at", "updated_at", "product_type", "award", "total_count", "end_time"]},
          :win_user => {:only => ["id", "phone", "nickname", "headimgurl"]},
          :lottery_orders =>{only: ["id", "lottery_id", "user_id", "request_ip", "total_count", "total_price", "is_win", "status", "address_id", "created_at", "updated_at", "user", "product", "lottery_order_items"] },
          :lottery_order =>{only: ["id", "lottery_id", "user_id", "request_ip", "total_count", "total_price", "is_win", "status", "address_id", "created_at", "updated_at", "user", "product", "lottery_order_items"] }
      }
  }

  def reduce_inventory_count
    if self.product.present?
      count = self.product.inventory_count - 1
      self.product.update_attributes!(inventory_count: count)
    end

  end

  def can_lottery?(current_user)
    if self.interval.to_i > 0
      !Lottery.where(product_id: self.product_id, win_user_id: current_user.id).where("lottery_time > ? ", (Date.today - self.interval).end_of_day).exists? && !Lottery.includes(:lottery_orders).where(product_id: self.product_id, status: 1, "lottery_orders.user_id" => current_user.id).exists?
    else
      return true
    end
  end

  def user_left_count(user_id)
    self.max_total_count - $redis.get("lottery_count:#{self.id}:#{user_id}").to_i
  end

  def max_total_count
    # (self.total_count * SYSTEMCONFIG[:lottery_max_count_persent].to_f).ceil
    (self.total_count * self.lottery_percent).ceil
  end

  def left_count
    r = $redis.get("lottery:#{self.id}").to_i
    r > 0 ? r : 0
  end

  def system_lotter_order_create
    if self.product_type == 1 && self.product.product_second_type == 0
      system_count = (self.total_count * SYSTEMCONFIG[:lottery_system_persent].to_f).ceil
      if (system_count > 0)
        $redis.decrby("lottery:#{self.id}", system_count)
        self.lottery_orders.create(user_id: 0, request_ip: "127.0.0.1", total_count: system_count, total_price: system_count * self.price, redis_left_count: self.total_count - system_count)
        self.with_lock do
          self.update(sales_count: self.sales_count + system_count)
          if system_count == self.total_count
            self.update(status: 1)
          end
        end
      end
    end
  end

  def init_redis_left_count
    $redis.set("lottery:#{self.id}", self.total_count - self.lottery_order_items.count)
  end

  def init_redis
    $redis.set("lottery:#{self.id}", self.total_count - self.lottery_order_items.count)
    self.lottery_orders.each do |lottery_order|
      $redis.incrby("lottery_count:#{self.id}:#{lottery_order.user_id}", lottery_order.total_count)
    end
  end

  #抽奖结束后过期改期抽奖的redis keys
  def clear_redis_keys
    if self.status >= 2 && self.lottery_order_items.count == self.total_count && self.lottery_orders.sum(:total_count) == self.total_count
      $redis.keys("lottery_count:#{self.id}:*").each do |key|
        $redis.expire(key, rand(10))
      end
    end
  end

  #用户抽奖 逻辑
  def lottery_order_create(current_user, total_count, request_ip)
    if total_count < 1
      return {status: 500, msg: "本期每人最多参与#{self.max_total_count}次<br>您还可以参与#{self.max_total_count - $redis.get("lottery_count:#{self.id}:#{current_user.id}").to_i}次", data: {}}
    end

    if self.published_at.blank? || self.published_at > Time.now
      return {status: 500, msg: '未到抽奖时间', data: {}}
    end

    if self.end_time && self.end_time < Time.now
      return {status: 500, msg: '已过期', data: {}}
    end
    unless can_lottery?(current_user)
      return {status: 500, msg: '已经中过该奖品， 请换一个奖品抽奖', data: {}}
    end
    #每人期购买次数限制
    count = $redis.incrby("lottery_count:#{self.id}:#{current_user.id}", total_count)
    Rails.logger.info("incrby #{total_count} #{current_user.id}")
    if (count > self.max_total_count)
      $redis.decrby("lottery_count:#{self.id}:#{current_user.id}", total_count)
      Rails.logger.info("decrby #{total_count} #{current_user.id}")
      return {status: 500, msg: "本期每人最多参与#{self.max_total_count}次<br>您还可以参与#{total_count - (count - self.max_total_count)}人次", data: {}}
    end

    redis_left_count = $redis.decrby("lottery:#{self.id}", total_count)
    res = {}
    if redis_left_count >= 0
      begin
        current_user.with_lock do
          if current_user.total_diamond_coin >= total_count * self.price
            self.lottery_orders.create!(user_id: current_user.id, request_ip: request_ip, total_count: total_count, total_price: total_count * self.price, redis_left_count: redis_left_count)
            current_user.diamond_accounts.create!(amount: -total_count * self.price, diamond_type: DiamondAccount::DIAMONDTYPE["夺宝"])
            if redis_left_count == 0
              self.update_attributes!(status: 1, lottery_end_time: Time.now, lottery_time: Time.now + 24 * 3000)
              Lottery.lottery_auto_extension(self.id) #自动延期
            end
            res = {status: 200, msg: '购买成功', data: current_user.subscribe_status}
          else
            $redis.incrby("lottery:#{self.id}", total_count)
            $redis.decrby("lottery_count:#{self.id}:#{current_user.id}", total_count)
            res = {status: 500, msg: '钻石币不足', data: current_user.subscribe_status}
          end
        end
      rescue Exception => e
        Rails.logger.info("夺宝失败")
        Rails.logger.info("#{current_user.id}, #{total_count}")
        Rails.logger.info(e)
        if current_user.total_diamond_coin >= total_count * self.price
          $redis.incrby("lottery:#{self.id}", total_count)
          $redis.decrby("lottery_count:#{self.id}:#{current_user.id}", total_count)
        end
        res = {status: 500, msg: "系统繁忙，请稍后重试", data: {}}
      end
      return res
    else
      $redis.incrby("lottery:#{self.id}", total_count)
      $redis.decrby("lottery_count:#{self.id}:#{current_user.id}", total_count)
      {status: 500, msg: "只剩下#{redis_left_count + total_count}次抽奖机会", data: {}}
    end

  end


  def self.prize_draw
    Lottery.where(status: 1).each do |lottery|
      lottery.prize_draw
    end
  end

  #开奖模块
  def prize_draw(cqssc = nil, num = 0)
    items = self.lottery_order_items.order("created_at")
    #开奖判断抽奖号码不够总数时 不开奖
    return false if items.count != self.total_count
    last_order_time = items.last.created_at
    cqssc = Cqssc.lottery_opencode(self.lottery_orders.order("created_at").last.created_at, num) unless cqssc
    if cqssc
      time_sum = items.last(50).inject(0) { |sum, x| sum += x.created_at.strftime("%H%M%S%L").to_i }
      cqssc_code = cqssc.opencode.delete(",").to_i
      diamond_price_30 = Dialink::DiamondPriceHistory.where(stock_code: "403011").where("date_time <= ?", last_order_time).order("date_time desc").limit(1).first.price
      diamond_price_50 = Dialink::DiamondPriceHistory.where(stock_code: "405011").where("date_time <= ?", last_order_time).order("date_time desc").limit(1).first.price
      lottery_code = (((diamond_price_30 + diamond_price_50) * 100 + cqssc_code + time_sum).to_i % self.total_count).to_i + LotteryOrderItem::BEGINNUMBER
      lottery_order_item = items.where(lottery_code: lottery_code).first
      if lottery_order_item && lottery_order_item.user_id != 0
        ActiveRecord::Base.transaction do
          lottery_order_item.lottery_order.update_attributes!(is_win: true)
          lottery_order_item.update_attributes!(is_win: true)
          self.update_attributes!(status: 2, win_user_id: lottery_order_item.user_id, win_lottery_code: lottery_order_item.lottery_code, lottery_time: Time.now, num_b: ((diamond_price_30 + diamond_price_50) * 100 + cqssc_code).to_i, num_a: time_sum.to_i, participant_time: items.where(user_id: lottery_order_item.user_id).count)
          self.lottery_give_diamond(lottery_order_item.lottery_order) #赠送钻币
          if lottery_order_item.user_id == 0
            LotteryOrderRefundJob.delay_for(10.seconds).perform_now(self.id)
            product = self.product
            product.with_lock do
              product.update_attributes!(inventory_count: product.inventory_count + 1)
            end
          end
          self.notice_lottery_winner
        end
      elsif lottery_order_item && lottery_order_item.user_id == 0 && num < 100
        self.prize_draw(nil, num + 1)
      else
        return nil
      end
    end
    return nil
  end

  def notice_lottery_winner
    win_user = self.win_user
    if win_user && win_user.phone
      Message.create(psz_mobis: win_user.phone, psz_msg: "恭喜您战胜了所有对手，【#{self.product.name}】归您了，快来完善信息接收礼品吧！我们会为您保留72小时", i_mobi_count: 1, request_ip: "127.0.0.1", is_voice: false)
    end
    wechat_notice
  end

  def wechat_notice
    begin
      if win_user && win_user.openid
        message = {
            "touser": "#{win_user.openid}",
            "msgtype": "news",
            "news": {
                "articles": [
                    {
                        "title": "您信，或不信，您中的奖品就在这里！",
                        "description": "您的运气好到爆！您在钻石大富翁【0元夺宝】参与的夺宝中，战胜了所有对手，赢得了商品【#{self.product_name}】！快来领取奖品吧！我们会为您保留72小时哦！【点击领奖】",
                        "url": "#{SYSTEMCONFIG[:host]}/h5/lotteries/#{self.id}",
                        "picurl": "#{SYSTEMCONFIG[:host]}/#{self.product.head_image}"
                    }
                ]
            }
        }
        Wechat.api.custom_message_send(message)
      end
    rescue Exception => e
    end
  end

  def refund_diamond_account
    if !self.win_lottery_code.blank? && self.win_user_id == 0 && self.lottery_time
      self.lottery_orders.each do |lottery_order|
        ActiveRecord::Base.transaction do
          lottery_order.with_lock do
            if lottery_order.is_refund == false
              lottery_order.update_attributes!(is_refund: true)
              if lottery_order.user_id > 0
                DiamondAccount.create!(user_id: lottery_order.user_id, amount: lottery_order.total_price, diamond_type: DiamondAccount::DIAMONDTYPE["夺宝退款"], table_type: "Lottery", table_id: self.id)
              end
            end
          end
        end
      end
    end
  end

  # 某期夺宝某用户抽奖记录
  def lottery_orders_by(user)
    self.lottery_orders.where(user_id: user.id).order(:created_at)
  end

  # 夺宝中奖的订单
  def win_order
    self.lottery_orders.where(is_win: true).first
  end

  # 某用户在某福袋上的抽奖记录
  def bag_lottery_order_item_by(user)
    self.lottery_order_items.where(user_id: user.id).first
  end

  # 某用户所有夺宝记录
  def lottery_order_items_by(user)
    self.lottery_order_items.where(user_id: user.id)
  end

  after_create :push_count_to_redis
  after_create :system_lotter_order_create

  private
  def push_count_to_redis
    self.update!(product_price: self.product.price)
    $redis.set("lottery:#{self.id}", self.total_count)
  end

  def generate_code
    share_code = Utils.generate_uuid
    lottery_code = Utils.generate_random
    self.update_attributes({share_code: share_code, lottery_code: lottery_code})
  end

  def default_end_time
    self.end_time ||= '2099-01-01'
    self.published_at ||= Time.now
  end

  def generate_product_type
    self.update_attributes(product_type: self.product.product_type)
  end

end
