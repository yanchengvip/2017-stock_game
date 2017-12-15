module Admins
  module LotteryHelper
    extend ActiveSupport::Concern
    module ClassMethods
      #lottery自动延续到下一期
      #auto_extension_status是否自动延续下一期:  1:不自动延续,2:自动延续,3:已经完成自动延续,4:商品库存不足
      def lottery_auto_extension lottery_id
        begin
          lottery = Lottery.includes(:product).where(id: lottery_id).first
          if lottery.published_at > Time.now
            ErrorLog.create(title: '自动发布抽奖记录', desc: '自动发布的抽奖published_at还没到开奖时间')
            return false
          end
          if lottery && lottery.auto_extension_status == 2
            if lottery.product.inventory_count <= 0
              #库存不足
              lottery.update_attributes!(auto_extension_status: 4)
              return false
            end
            current_hour = Time.now.hour
            if current_hour >= lottery.auto_extension_start_time.to_i && current_hour < lottery.auto_extension_end_time.to_i
              published_at = Time.now + (lottery.auto_extension_interval.to_i).minutes
            else
              published_at = Time.now.beginning_of_day + (lottery.auto_extension_start_time.to_i).hours if current_hour <= lottery.auto_extension_start_time.to_i
              published_at = Time.now.end_of_day + (lottery.auto_extension_start_time.to_i).hours if current_hour > lottery.auto_extension_start_time.to_i
            end
            lottery.update_attributes!(auto_extension_status: 3)
            Lottery.create!(product_id: lottery.product_id, published_at: published_at, sort: lottery.sort.to_i, product_name: lottery.product_name,
                           total_count: lottery.total_count, price: lottery.price, auto_extension_lottery_id: lottery.id,
                           interval: lottery.interval.to_i, lottery_percent: lottery.lottery_percent,
                           auto_extension_interval: lottery.auto_extension_interval, auto_extension_status: 2,
                           auto_extension_start_time: lottery.auto_extension_start_time, auto_extension_end_time: lottery.auto_extension_end_time)

          end
        rescue Exception => e
          ErrorLog.create(title: "lottery延期自动发布抽奖lottery_id=#{lottery_id}", desc: 'lottery延期失敗....' + e.to_s)
        end

      end


    end


    #夺宝商品赠送钻币
    def lottery_give_diamond lottery_order
      begin
        if self.product.product_second_type == 1
          lottery_order.update_attributes!(status: 1)
          self.update_attributes!(take_award: true)
          self.diamond_accounts.create!(user_id: lottery_order.user_id, amount: self.product.diamond_num.to_i,
                                        diamond_type: DiamondAccount::DIAMONDTYPE["0元夺宝中奖赠送"])
        end
      rescue Exception => e
        ErrorLog.create(title: '夺宝商品赠送钻币失败-e1', desc: e.to_s)
      end

    end


  end

end
