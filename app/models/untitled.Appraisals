begin
      r = ActiveRecord::Base.transaction do
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
          HoldDiamond.flush_user_diamonds(self.user_id, self.sale_diamond_id)
          user = self.user
          user.update_attributes!(hold_diamonds_count: HoldDiamond.user_diamonds(user.id).count)

          profit = hold_diamonds.inject(0){|sum, x| sum +=  x.sell_price - x.buy_price }

          diamond_trade = DiamondTrade.create!(booking_trade_id: self.id, user_id: self.user_id, bussiness_type: self.bussiness_type, total_count: self.total_count, total_price: self.total_count * self.booking_price, sale_diamond_id: self.sale_diamond_id, fee: fee, profit: profit, price: sale_diamond.current_price)

          user.gold_accounts.create(amount: (total_price - fee).to_f.round(2), available_gold_amount: (total_price - fee).to_f.round(2), account_type: 2, table_type: "DiamondTrade", table_id: diamond_trade.id)
        end
      end
      return true
    rescue Exception => e
      puts e.message
      Rails.logger.info(e)
      return false
    end
