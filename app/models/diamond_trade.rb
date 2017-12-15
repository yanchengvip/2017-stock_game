class DiamondTrade < ApplicationRecord
  belongs_to :sale_diamond
  belongs_to :booking_trade
  self.xml_options = {
    :only => ["id", "booking_trade_id", "user_id", "sale_diamond_id", "bussiness_type", "total_count", "total_price", "created_at", "updated_at", "fee", "profit", "close_shorting_status", "price"],
    :include => {
      :sale_diamond => { :only => ["id", "name", "is_published", "min_size", "max_size", "exchange_name", "exchange_code", "color", "clarity", "current_price", "opening_price", "created_at", "updated_at", "yesterday_close_pirce", "max_price", "min_price", "opening_price_day", "cn_name"]}
    }
  }

  def can_close?
    self.created_at < (Date.today - SYSTEMCONFIG[:trade_time_interval_days]).to_time.at_end_of_day
  end
end
