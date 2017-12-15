class HoldDiamond < ApplicationRecord
  belongs_to :user
  belongs_to :sale_diamond
  scope :can_sell?, -> {where("created_at < ?",  (Date.today - SYSTEMCONFIG[:trade_time_interval_days]).to_time.at_end_of_day)}

  #status 持有 0 挂单卖 1 卖出 2
  STATUSCONfIG = {
    "buy" => 0,
    "sell" => -1,
    "pending" => 1
  }.with_indifferent_access.freeze

  def self.position_info(current_user)
    hold_diamonds = HoldDiamond.includes(:sale_diamond).where(user_id: current_user.id, "sale_diamonds.is_published" => true, status: [0,1]).group_by{|x| x.sale_diamond_id}
    res = []
    hold_diamonds.each do |key, value|
      sale_diamond = value.first.sale_diamond
      res << {
          id: sale_diamond.id,
          cn_name: sale_diamond.cn_name,
          exchange_name: sale_diamond.exchange_name,
          exchange_code: sale_diamond.exchange_code,
          total_count: value.size,
          available_count: value.select{|x|x.created_at <  (Date.today - SYSTEMCONFIG[:trade_time_interval_days]).to_time.at_end_of_day && x.status == 0}.size,
          avg_price: (value.inject(0){|sum, x| sum += x.buy_price} /  value.size).round(2),
          market_price: Dialink::DiamondPriceHistory.market_price(sale_diamond.exchange_code),
          total_market_price: Dialink::DiamondPriceHistory.market_price(sale_diamond.exchange_code) * value.size,
          total_profit: Dialink::DiamondPriceHistory.market_price(sale_diamond.exchange_code) * value.size - value.inject(0){|sum, x| sum += x.buy_price}
        }
    end
    res
  end


  def self.hold_diamonds_info user_id
    $cache.fetch("hold_diamonds_info_#{user_id}", 60){
      HoldDiamond.where(user_id: user_id, status: [0, 1]).group_by{|x| x.sale_diamond_id}.inject({}){ |res, key_value|
        res[key_value[0]] = key_value[1].size
        res
      }
    }
  end

  #用户持有钻石数据
  def self.user_diamonds(user_id, sale_diamond_id = nil)
    $cache.fetch("user_diamonds_#{user_id}_#{sale_diamond_id}", 10*60){
      if sale_diamond_id
        HoldDiamond.where(user_id: user_id, sale_diamond_id: sale_diamond_id,  status: [0,1]).to_a
      else
        HoldDiamond.where(user_id: user_id,  status: [0,1]).to_a
      end
    }
  end

  def self.available_diamonds(user_id, sale_diamond_id = nil)
    $cache.fetch("available_diamonds_#{user_id}_#{sale_diamond_id}", 60){
      if sale_diamond_id
        HoldDiamond.can_sell?.where(user_id: user_id, sale_diamond_id: sale_diamond_id,  status: 0).to_a
      else
        HoldDiamond.can_sell?.where(user_id: user_id,  status: 0).to_a
      end
    }
  end


  after_create :flush_user_diamonds
  after_save :flush_user_diamonds

  def self.flush_user_diamonds(user_id, sale_diamond_id=nil)
    $cache.delete("user_diamonds_#{user_id}_")
    $cache.delete("user_diamonds_#{user_id}_#{sale_diamond_id}")
    $cache.delete("available_diamonds_#{user_id}_#{sale_diamond_id}")
    $cache.delete("hold_diamonds_info_#{user_id}")
  end

  def flush_user_diamonds
    $cache.delete("user_diamonds_#{self.user_id}_")
    $cache.delete("user_diamonds_#{self.user_id}_#{self.sale_diamond_id}")
    $cache.delete("available_diamonds_#{self.user_id}_#{self.sale_diamond_id}")
    $cache.delete("hold_diamonds_info_#{self.user_id}")
  end
end
