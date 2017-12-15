class BookingTrade < ApplicationRecord
  #bussiness_type 1 挂单买    2挂单卖  3做空  4 做空平仓
  #status 0 正常，  -1 撤单 1 成交
  belongs_to :user
  belongs_to :sale_diamond
  has_one :diamond_trade

  self.xml_options = {
    :only => [:id, :sale_diamond_id, :total_count, :user_id, :bussiness_type, :booking_price, :status, :created_at, :updated_at, :diamond_trade_id].freeze,
    :include => {
      :sale_diamond => { :only => ["id", "name", "is_published", "min_size", "max_size", "exchange_name", "exchange_code", "color", "clarity", "current_price", "opening_price", "created_at", "updated_at", "yesterday_close_pirce", "max_price", "min_price", "opening_price_day", "cn_name"]}
    }
  }

  def cancle
    if self.status == 0
      r = ActiveRecord::Base.transaction do
        self.update_attributes!(status: -1)
        if self.bussiness_type ==  1
          user = self.user
          # user.update_attributes!(available_gold: user.available_gold + self.booking_price * self.total_count)

          user.gold_accounts.create!(available_gold_amount: (self.booking_price * self.total_count).to_f.round(2), account_type: -11, table_type: "BookingTrade", table_id: self.id  )

        elsif self.bussiness_type ==  2
          HoldDiamond.where(sale_diamond_id: self.sale_diamond_id, user_id: self.user_id, status: 1).order("buy_time desc").limit(self.total_count).update_all(status: 0)
        elsif self.bussiness_type ==  3
          user =  self.user
          # user.update_attributes!(available_gold: user.available_gold + self.booking_price * self.total_count * (1 + SYSTEMCONFIG[:admin_config][:diamond_trade_fee]) )
          user.gold_accounts.create!(available_gold_amount: (self.booking_price * self.total_count * (1 + SYSTEMCONFIG[:admin_config][:diamond_trade_fee])).to_f.round(2), account_type: -13, table_type: "BookingTrade", table_id: self.id  )

        elsif self.bussiness_type ==  4
          DiamondTrade.where(id: self.diamond_trade_id).each do |x|
            x.update_attributes!(close_shorting_status: 0)
          end
          # HoldDiamond.where(sale_diamond_id: self.sale_diamond_id, user_id: self.user_id, status: 1).order("buy_time desc").limit(self.total_count).update_all(status: 0)
        end
      end
      res = {status: 200, msg: "撤单成功", data: {} }
    else
      case self.status
      when 1
        res = {status: 500, msg: "该订单已经成交", data: {}}
      when -1
        res = {status: 500, msg: "该订单已经取消", data: {}}
      end
    end
    return res
  end

  #定时任务 看数据是否满足成交条件
  def self.check_price
    BookingTrade.where(status: 0).each do |booking_trade|
      booking_trade.check_price
    end
  end

  def check_price
    sale_diamond = self.sale_diamond
    res = false
    if self.status != 0
      res = true
    else
      if self.bussiness_type == 1 && sale_diamond.current_price <=self.booking_price
        res = buy_diamond(sale_diamond)
      elsif self.bussiness_type == 2 && sale_diamond.current_price >= self.booking_price
        res =  sell_diamond(sale_diamond)
      elsif self.bussiness_type == 3 && sale_diamond.current_price >= self.booking_price
        res =  shorting_diamond(sale_diamond)
      elsif self.bussiness_type == 4 && sale_diamond.current_price <= self.booking_price
        res =  close_shorting_diamond(sale_diamond)
      else
        res =  false
      end
    end
    return res
  end

  #做空 挂单成交
  def shorting_diamond(sale_diamond)
    begin
      self.with_lock do
        return true if self.status != 0
        self.update_attributes!(status: 1)
        total_price = self.total_count * sale_diamond.current_price
        diamond_trade = DiamondTrade.create!(booking_trade_id: self.id, user_id: self.user_id, bussiness_type: self.bussiness_type, total_count: self.total_count, total_price: total_price, sale_diamond_id: self.sale_diamond_id, fee: SYSTEMCONFIG[:admin_config][:diamond_trade_fee] * total_price, price: sale_diamond.current_price)

        user.gold_accounts.create!(amount: -(diamond_trade.total_price * (1 + SYSTEMCONFIG[:admin_config][:diamond_trade_fee])).to_f.round(2), available_gold_amount:  ((self.total_count * self.booking_price - diamond_trade.total_price) * (1 + SYSTEMCONFIG[:admin_config][:diamond_trade_fee] )).to_f.round(2), account_type: 3, table_type: "DiamondTrade", table_id: diamond_trade.id)
      end
      return true
    rescue Exception => e
      p e
      Rails.logger.info(e)
      return false
    end
  end

  #平仓 挂单成交
  def close_shorting_diamond(sale_diamond)
    begin
      self.with_lock do
        return true if self.status != 0
        self.update_attributes!(status: 1)
        close_diamond_trade = DiamondTrade.find(self.diamond_trade_id)

        diamond_trade = DiamondTrade.create!(booking_trade_id: self.id, user_id: self.user_id, bussiness_type: self.bussiness_type, total_count: self.total_count, total_price: self.total_count * sale_diamond.current_price, sale_diamond_id: self.sale_diamond_id, price: sale_diamond.current_price, profit: -(self.total_count * sale_diamond.current_price - close_diamond_trade.total_price))

        close_diamond_trade.update_attributes!(close_shorting_status: 2)

        user.gold_accounts.create!(amount: 2 * close_diamond_trade.total_price - diamond_trade.total_price, available_gold_amount: 2 * close_diamond_trade.total_price - diamond_trade.total_price, account_type: 4, table_type: "DiamondTrade", table_id: diamond_trade.id)
      end
      return true
    rescue Exception => e
      Rails.logger.info(e)
      return false
    end
  end

  #预订单买入钻石成交
  def buy_diamond(sale_diamond)
    begin
        self.with_lock do
          return true if self.status != 0
          self.update_attributes!(status: 1)
          diamond_trade = DiamondTrade.create!(booking_trade_id: self.id, user_id: self.user_id, bussiness_type: self.bussiness_type, total_count: self.total_count, total_price: self.total_count * sale_diamond.current_price, sale_diamond_id: self.sale_diamond_id, price: sale_diamond.current_price)
          self.total_count.times{
            HoldDiamond.create!(sale_diamond_id: self.sale_diamond_id, buy_price: sale_diamond.current_price, buy_time: Time.now, status: 0, diamond_trade_id: diamond_trade.id, user_id: self.user_id)}
          user = self.user
          user.update_attributes!(hold_diamonds_count: HoldDiamond.user_diamonds(user.id).count)
          # user.update_attributes!(total_gold: user.total_gold - diamond_trade.total_price, hold_diamonds_count: HoldDiamond.user_diamonds(user.id).count, available_gold: user.available_gold + self.total_count * self.booking_price - diamond_trade.total_price )

          user.gold_accounts.create!(amount: -diamond_trade.total_price, available_gold_amount: self.total_count * self.booking_price - diamond_trade.total_price , account_type: 1, table_type: "DiamondTrade", table_id: diamond_trade.id)
          HoldDiamond.flush_user_diamonds(self.user_id, self.sale_diamond_id)
        end
      p r
      return true
    rescue Exception => e
      Rails.logger.info(e)
      return false
    end

  end

  #预订单卖出钻石成交
  def sell_diamond(sale_diamond)
    begin
      self.with_lock do
        return true if self.status != 0
        booking_total_price = self.booking_price * self.total_count
        total_price = sale_diamond.current_price * self.total_count
        fee =  (total_price * SYSTEMCONFIG[:admin_config][:diamond_trade_fee]).round(2)
        self.update_attributes!(status: 1)

        hold_diamonds = HoldDiamond.where(sale_diamond_id: self.sale_diamond_id, user_id: self.user_id, status: 1).order("buy_time").limit(self.total_count).lock.update(sell_price: sale_diamond.current_price, sell_time: Time.now, status: 2)
        puts("------updates-------")
        if hold_diamonds.count < self.total_count
          Rails.logger.info("------订单异常， 持有钻石数量不足-------")
          puts("------订单异常， 持有钻石数量不足-------")
          raise "订单异常， 持有钻石数量不足"
        else
          hold_diamonds.each do |hold_diamond|
            hold_diamond.update_attributes!(sell_price: sale_diamond.current_price, sell_time: Time.now, status: 2)
          end

          user = self.user
          user.update_attributes!(hold_diamonds_count: HoldDiamond.user_diamonds(user.id).count)

          profit = hold_diamonds.inject(0){|sum, x| sum +=  x.sell_price - x.buy_price }

          diamond_trade = DiamondTrade.create!(booking_trade_id: self.id, user_id: self.user_id, bussiness_type: self.bussiness_type, total_count: self.total_count, total_price: self.total_count * self.booking_price, sale_diamond_id: self.sale_diamond_id, fee: fee, profit: profit, price: sale_diamond.current_price)

          user.gold_accounts.create!(amount: (total_price - fee).to_f.round(2), available_gold_amount: (total_price - fee).to_f.round(2), account_type: 2, table_type: "DiamondTrade", table_id: diamond_trade.id)
          HoldDiamond.flush_user_diamonds(self.user_id, self.sale_diamond_id)
        end
      end
      return true
    rescue Exception => e
      puts e.message
      Rails.logger.info(e)
      return false
    end

  end


  def self.create_booking_trade(params, current_user)
    params.each do |k, v|
      params[k] = v.to_f
    end
    params[:user_id] = current_user.id
    res  = {}
    if params["bussiness_type"] == 1
      res = BookingTrade.create_buy_booking_trade params, current_user
    elsif params["bussiness_type"] == 2
      res = BookingTrade.create_sell_booking_trade params, current_user
    elsif params["bussiness_type"] == 3
      res = BookingTrade.create_shorting_booking_trade params, current_user
    elsif params["bussiness_type"] == 4
      res = BookingTrade.create_close_shorting_booking_trade params, current_user
    else
      res = {status: 500, msg: "网络异常，请稍后重试", data: {}}
    end
    HoldDiamond.flush_user_diamonds(current_user.id)
    HoldDiamond.flush_user_diamonds(current_user.id, params[:sale_diamond_id])
    return res
  end

  #创建做空挂单
  def self.create_shorting_booking_trade  params, current_user
    res = {}
    sale_diamond = SaleDiamond.find(params[:sale_diamond_id])
    if sale_diamond && params[:booking_price] >= (sale_diamond.yesterday_close_pirce * 0.9).round(2) && params[:booking_price] <= (sale_diamond.yesterday_close_pirce * 1.1).round(2) && current_user.available_gold >= (params[:booking_price] * params[:total_count]) * ( 1 + SYSTEMCONFIG[:admin_config][:diamond_trade_fee] )
      begin
        ActiveRecord::Base.transaction do
          booking_trade = BookingTrade.create!(params)
          # current_user.update_attributes!(available_gold: (current_user.available_gold - (params[:booking_price] * params[:total_count]) * ( 1 + SYSTEMCONFIG[:admin_config][:diamond_trade_fee] )))
          current_user.gold_accounts.create!(available_gold_amount: -((params[:booking_price] * params[:total_count] * ( 1 + SYSTEMCONFIG[:admin_config][:diamond_trade_fee])).round(2)), account_type: 13, table_type: "BookingTrade", table_id: booking_trade.id  )
          BookingTradeCheckJob.delay_for(1.seconds).perform_now(booking_trade.id)
        end
        res = { status:200, msg: '操作成功', data: {}}
      rescue Exception => e
        res = { msg: "提交数据失败，稍后重试", status:500, data: {}}
      end
    else
      res = {status: 500, msg: "提交数据失败，稍后重试", data: {}}
    end
  end

  #创建做空平仓 挂单
  def self.create_close_shorting_booking_trade  params, current_user
    res = {}
    diamond_trade = DiamondTrade.where(user_id: current_user.id, id: params[:diamond_trade_id]).first
    sale_diamond = SaleDiamond.find(diamond_trade.sale_diamond_id)
    if diamond_trade && !diamond_trade.can_close?
      res = {status: 500, msg: "T+#{SYSTEMCONFIG[:trade_time_interval_days]}日后可交易", data: {}}
      return res
    end
    diamond_trade.with_lock do
      if diamond_trade && sale_diamond && params[:booking_price] >= (sale_diamond.yesterday_close_pirce * 0.9).round(2) && params[:booking_price] <= (sale_diamond.yesterday_close_pirce * 1.1).round(2) && diamond_trade.close_shorting_status == 0
        begin
          ActiveRecord::Base.transaction do
            booking_trade = BookingTrade.create!(sale_diamond_id: diamond_trade.sale_diamond_id, total_count: diamond_trade.total_count, user_id: current_user.id, bussiness_type: params[:bussiness_type], booking_price: params[:booking_price], diamond_trade_id: params[:diamond_trade_id])
            diamond_trade.update_attributes!(close_shorting_status: 1)
            BookingTradeCheckJob.delay_for(1.seconds).perform_now(booking_trade.id)
          end
          res = { status:200, msg: '操作成功', data: {}}
        rescue Exception => e
          res = { msg: "系统异常", status:500, data: {}}
        end
      else
        if(diamond_trade.close_shorting_status == 1)
          res = {status: 500, msg: "已经挂单", data: {}}
        elsif (diamond_trade.close_shorting_status == 2)
          res = {status: 500, msg: "已经平仓", data: {}}
        else
          res = {status: 500, msg: "系统异常", data: {}}
        end
      end
    end
    res
  end

  #创建买 挂单
  def self.create_buy_booking_trade params, current_user
    res = {}
    sale_diamond = SaleDiamond.find(params[:sale_diamond_id])
    if sale_diamond && params[:booking_price] >= (sale_diamond.yesterday_close_pirce * 0.9).round(2) && params[:booking_price] <= (sale_diamond.yesterday_close_pirce * 1.1).round(2) && current_user.available_gold >= params[:booking_price] * params[:total_count]
      begin
        ActiveRecord::Base.transaction do
          booking_trade = BookingTrade.create!(params)
          # current_user.update_attributes!(available_gold: (current_user.available_gold -  params[:booking_price] * params[:total_count]))
          current_user.gold_accounts.create!( available_gold_amount: -params[:booking_price] * params[:total_count], account_type: 11, table_type: "BookingTrade", table_id: booking_trade.id)
          BookingTradeCheckJob.delay_for(1.seconds).perform_now(booking_trade.id)
        end
        res = { status:200, msg: '操作成功', data: {}}
      rescue Exception => e
        res = { msg: "系统异常",status:500, data: {}}
      end
    else
      res = {status: 500, msg: "系统异常", data: {}}
    end
    return res
  end

  #创建卖 挂单
  def self.create_sell_booking_trade params, current_user
    res = {}
    sale_diamond = SaleDiamond.find(params[:sale_diamond_id])
    if sale_diamond && params[:booking_price] >= (sale_diamond.yesterday_close_pirce * 0.9).round(2) && params[:booking_price] <= (sale_diamond.yesterday_close_pirce * 1.1).round(2) && HoldDiamond.available_diamonds(current_user.id, sale_diamond.id).count >= params[:total_count]
      begin
        ActiveRecord::Base.transaction do
          booking_trade = BookingTrade.create!(params)
          HoldDiamond.where(user_id: current_user.id, sale_diamond_id: sale_diamond.id, status: 0).order("buy_time").limit(params[:total_count]).lock.update_all(status: 1)
          HoldDiamond.flush_user_diamonds(current_user.id, sale_diamond.id)
          BookingTradeCheckJob.delay_for(1.seconds).perform_now(booking_trade.id)
          # BookingTradeCheckJob.perform_now(booking_trade.id)
        end
        res = { status:200, msg: '操作成功', data: {}}
      rescue Exception => e
        res = {msg: "系统异常",status:500, data: {}}
      end
    else
      res = {status: 500, msg: "挂单价格异常或账户可卖钻石数量不足", data: {}}
    end
    return res
  end

  after_save :flush_user_diamonds
  after_create :flush_user_diamonds

  def flush_user_diamonds
    HoldDiamond.flush_user_diamonds(self.user_id)
    HoldDiamond.flush_user_diamonds(self.user_id, self.sale_diamond_id)
  end
end
