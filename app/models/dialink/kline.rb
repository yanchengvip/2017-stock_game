class Dialink::Kline < Dialink::DialinkConnection
  def self.kline_data(stock_code)
    $cache.fetch("kline_data_#{stock_code}_#{Date.today.to_s}" , 60){
      res = []
      last_close_price = nil
      Dialink::Kline.where(stock_code: stock_code).order("day asc").each_with_index do |x, index|
        if index == 0
          last_close_price = x.close_price.to_f
        end
        r = [Date.parse(x.day).to_time.to_i * 1000, x.open_price.to_f, x.close_price.to_f, x.max_price.to_f, x.min_price.to_f,  x.total_count.to_i]
        r[6] = 0
        r[7] = 0
        r[8] = 0
        r[9] = 0
        r[10] = last_close_price
        res << r
        last_close_price = x.close_price.to_f
     end
     res
    }
  end
end
