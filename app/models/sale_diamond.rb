class SaleDiamond < ApplicationRecord
  has_many :hold_diamonds
  scope :is_published, -> {where(is_published: true)}

  def self.crawler_price
    res = Faraday.new.get("http://ta.hncae.net/front/hq/delay_hq.json?stockPreCodes=4").body
    json = JSON.parse(res.gsub(/jsonpCallback\(([\w\W]*)\)/){$1}).first
    data = json["stockList"].select{|x| ["403011", "405011"].include? x["hqzqdm"] }
    data.each do |d|
      if d["hqzjcj"].to_f > 0
        sale_diamond = SaleDiamond.where(exchange_code: d["hqzqdm"]).first
        sale_diamond.update(current_price: d["hqzjcj"], opening_price: d["hqjrkp"],  yesterday_close_pirce: d["hqzrsp"], max_price: d["hqzgcj"], min_price: d["hqzdcj"], opening_price_day: Date.today.to_s)
      end
    end
  end

  def self.diamond_history_price stock_code
    time = Time.now
    day = Date.today
    day = day - 1 if(time - Date.today.to_time < 9 * 3600)
     $cache.fetch("diamond_history_prices_#{stock_code}_#{time.at_beginning_of_minute.strftime('%Y%m%d%H%M%S')}", 10){
      data = {}

      b = 3600*9.5*1000 + day.beginning_of_day.to_i * 1000;
      (0...121).each do |i|
        data[b] = nil
        b = b + 60000;
      end

      b = 3600*13*1000 + day.beginning_of_day.to_i * 1000;
      (0...121).each do |i|
        data[b] = nil
        b = b + 60000;
      end

      res = Dialink::DiamondPriceHistory.select(:date_time, :price, :day_avg_price).where("date_time > '#{day.to_time}' and stock_code = ? ",  stock_code).to_a
      m_line = res.map{|x| [x.date_time.to_i*1000, x.price.to_f.round(2)]}.to_h
      a_line = res.map{|x| [x.date_time.to_i*1000, x.day_avg_price.to_f.abs.round(2)]}.to_h
      m_line = data.merge(m_line).to_a.sort{|x, y| x[0] <=> y[0]}
      a_line = data.merge(a_line).to_a.sort{|x, y| x[0] <=> y[0]}
      [m_line, a_line]
    }
  end

  def self.current_prices
    minute = Time.now.at_beginning_of_minute.strftime('%Y-%m-%d %H:%M:%S')
    $cache.fetch("sale_diamonds_price_#{minute}", 10){
      res = {}
      SaleDiamond.where(is_published: true).each do |sale_diamond|
        if diamond_price_history = Dialink::DiamondPriceHistory.where(stock_code: sale_diamond.exchange_code).order("date_time desc").limit(1).first
          res[sale_diamond.id] = diamond_price_history.price
        end
      end
      res
    }
  end

  #每天1点执行 更新昨日收盘价和今日开盘价
  def self.update_opening_price
    SaleDiamond.where(is_published: true).each do |sale_diamond|
      if kline = Dialink::Kline.where(stock_code: sale_diamond.exchange_code).where("day = ? ", Date.yesterday.to_s).first
        sale_diamond.update(opening_price: kline.close_price, yesterday_close_pirce: kline.close_price, max_price: 0, min_price: 0)
      else
        Rails.logger.info("#{Date.yesterday.to_s} Kline cal error")
      end
    end
  end

  def self.update_all_price
    SaleDiamond.where(is_published: true).each do |sale_diamond|
      begin
        sale_diamond.update_all_price
      rescue Exception => e
      end
    end
  end
  # SaleDiamond(current_price: decimal, max_price: decimal, min_price: decimal)
  def update_all_price
    params = {}
    details = Dialink::BourseDetail.where("entrust_time > ? and stock_code = ?", Time.now.beginning_of_day, self.exchange_code).order(:entrust_time)
    prices = details.map{|x| x.match_price.abs }
    price_min = prices.min.to_f
    price_max = prices.max.to_f
    params[:current_price] = Dialink::DiamondPriceHistory.market_price(self.exchange_code, true)
    if self.max_price.to_f == 0 || self.max_price.to_f  < price_max
      params[:max_price] = price_max
    end
    if self.min_price.to_f  == 0 || self.min_price.to_f  > price_min
      params[:min_price] = price_min
    end

    #更新开盘价
    if self.opening_price_day != Date.today.to_s && detail = Dialink::BourseDetail.where("entrust_time > ? and stock_code = ?", Time.now.beginning_of_day, self.exchange_code).order(:entrust_time).first
      params[:opening_price_day] = Date.today.to_s
      params[:opening_price] = detail.match_price.abs
    end
    self.update(params)
  end

end
