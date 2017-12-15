module Admins
  module Users
    module UsersSubscribeHelper
      extend ActiveSupport::Concern

      module ClassMethods

        #用户每天关注/取消关注统计
        def users_everyday_subscribe_data
          sign_logs = UserSignLog.select('user_status', 'count(id) as user_count')
                          .where('user_status in (1,2) and created_at <= ? and created_at >= ? ', Time.now.end_of_day, Time.now.beginning_of_day)
                          .group('user_status')
          subscribe_count, unsubscribe_count, wechat_diamont_count, sign_diamont_count, yao_diamont_count, gold_to_diamond, consume_diamond = 0
          sign_logs.each do |sign|
            case sign.user_status.to_i
              when 1
                #用户当天关注人数
                subscribe_count = sign.user_count
              when 2
                #用户当天取消关注人数
                unsubscribe_count = sign.user_count
            end
          end
          #当天净增关注人数
          pure_count = subscribe_count.to_i - unsubscribe_count.to_i
          #累计关注人数
          all_wechat_count = User.where('openid is not null').count
          #当日累计注册用户
          day_all_count = User.where('created_at <= ? and created_at >= ?', Time.now.end_of_day, Time.now.beginning_of_day).count
          #当日开奖期数
          lottery_count = Lottery.where('status != ? and lottery_time <= ? and lottery_time >= ?', -1, Time.now.end_of_day, Time.now.beginning_of_day).count
          #当日新上架的商品数量
          new_product_count = Product.where('created_at <= ? and created_at >= ?', Time.now.end_of_day, Time.now.beginning_of_day).count
          #当日剩余未开奖商品数
          no_lottery_pro = Lottery.select('product_id').where(status: [0, 1]).distinct.count
          #当日登录人数
          login_count = UserLoginLog.where('created_at <= ? and created_at >= ?', Time.now.end_of_day, Time.now.beginning_of_day).count
          #当日参与夺宝用户数
          lottery_users = LotteryOrder.where('created_at <= ? and created_at >= ?', Time.now.end_of_day, Time.now.beginning_of_day).count
          dias = DiamondAccount.select('diamond_type', 'sum(amount) as amount')
                     .where('diamond_type in (1,2,30,31,38) and created_at <= ? and created_at >= ?', Time.now.end_of_day, Time.now.beginning_of_day)
                     .group('diamond_type')
          dias.each do |dia|
            case dia.diamond_type.to_i
              when 1
                #当日消耗钻币
                consume_diamond = dia.amount.to_f
              when 2
                #虚拟资金兑换获得的钻币
                gold_to_diamond = dia.amount.to_f
              when 30
                #当日注册发放的获取钻币数
                sign_diamont_count = dia.amount.to_f
              when 31
                #邀请好友获得钻币数
                yao_diamont_count = dia.amount.to_f
              when 38
                #当日关注微信获取钻币数
                wechat_diamont_count = dia.amount.to_f

            end
          end

          #可用钻币总额
          total_diamond_coin = User.sum('total_diamond_coin')

          data = [Time.now.strftime('%Y-%m-%d'), subscribe_count.to_i, unsubscribe_count.to_i, pure_count.to_i, all_wechat_count.to_i, day_all_count.to_i, lottery_count.to_i, new_product_count.to_i,
                  no_lottery_pro.to_i, login_count.to_i, lottery_users.to_i, wechat_diamont_count.to_f, sign_diamont_count.to_f, yao_diamont_count.to_f,
                  gold_to_diamond.to_f, consume_diamond.to_f, total_diamond_coin.to_f]

        end


      end


      module InstanceMethods

      end
    end
  end

end