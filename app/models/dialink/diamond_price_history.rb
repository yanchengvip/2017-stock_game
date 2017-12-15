class Dialink::DiamondPriceHistory < Dialink::DialinkConnection
  def self.market_price(stock_code, flush = false)
    $cache.delete("market_price_#{stock_code}") if(flush)
    $cache.fetch("market_price_#{stock_code}", 10){
      if diamond_price_history = Dialink::DiamondPriceHistory.where(stock_code: stock_code).order("date_time desc").limit(1).first
        diamond_price_history.price
      else
        0
      end
    }
  end

  def self.all_diamonds_his_price(date_time)
    res = Hash.new(0)
    SaleDiamond.all.each do |sale_diamond|
      if diamond_price_history = Dialink::DiamondPriceHistory.where(stock_code: sale_diamond.exchange_code).where("date_time <= ?", date_time).order("date_time desc").limit(1).first
        p diamond_price_history
        res[sale_diamond.id] = diamond_price_history.price
      end
    end
    res
  end
end
