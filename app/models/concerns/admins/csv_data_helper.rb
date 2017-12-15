module Admins
  module CsvDataHelper
    extend ActiveSupport::Concern
    module ClassMethods

      #用户基本情况统计下载
      def user_info_scv_data params
        data_arr = []
        share_users_num = lottery_count_num = win_count_num = coin_count_num = coin_lottery_total_num = trade_count_num = trade_price_num = 0
        users = User.user_info_data params
        users.each do |user|
          signup_time = user.created_at.strftime('%Y-%m-%d %H:%M')
          share_users = user.share_users.length #邀请的用户数量
          user_login_count = user.user_login_logs.length #登录天数(活跃度)
          lottery_count = user.lottery_order_items.length #夺宝次数
          win_count = user.lottery_order_win_items.length #中奖次数
          coin_count = user.coin_bag_coin_count.to_f #钻币礼包抽奖中奖金额
          trade_count = user.diamond_trades.length #虚拟盘交易次
          coin_lottery_num = user.coin_bag_lottery_items.length #钻币礼包抽奖次数
          trade_price = user.trade_total_price.to_f #虚拟盘交易金额


          #是否关注微信公众号
          is_sub_wechat = '否'
          if user.subscribe_status.to_i == 1
            is_sub_wechat = '是'
          end
          #注册渠道（渠道名称、邀请者用户名、空）
          parent_user_name = '无'
          #注册来源
          sign_source = '直接注册'
          if user.parent_user.present?
            #邀请者用户名
            parent_user_name = user.parent_user.nickname
            sign_source = '邀请注册'
          else
            q = QrcodeScanRecord.includes(:qrcode).where(openid: user.openid).first
            parent_user_name = q.qrcode.user_name if q.present?
            sign_source = '扫码注册'  if q.present?
          end
          data_arr << [user.id, user.nickname, user.phone, signup_time, is_sub_wechat,sign_source,parent_user_name,
                       share_users, user_login_count, lottery_count, win_count, coin_lottery_num, coin_count, trade_count, trade_price]

          share_users_num += share_users #邀请的用户数量合计
          lottery_count_num += lottery_count #夺宝次数合计
          win_count_num += win_count #中奖次数合计
          coin_count_num += coin_count #中奖金额合计
          coin_lottery_total_num += coin_lottery_num
          trade_count_num += trade_count #虚拟盘交易次合计
          trade_price_num += trade_price #虚拟盘交易金额合计

        end
        if !params[:is_web_table]
          data_arr << [users.length, '', '', '', '','','', share_users_num, '', lottery_count_num, win_count_num, coin_count_num, coin_lottery_total_num, trade_count_num, trade_price_num]
        end
        return data_arr,users
      end


      #资金余额统计下载
      def remain_balance_scv_data params
        data_arr = []
        ga1_amount_num = usable_gold_num = da1_amount_num = 0
        users = User.remain_balance_data_hash params
        users.each do |user|
          signup_time = user.created_at.strftime('%Y-%m-%d %H:%M') #注册时间
          signup_source = user.openid.nil? ? 'h5注册' : '微信注册'
          ga1_amount = user.ga1_amount.to_f #虚拟资金余额
          usable_exchange_gold = (user.ga1_amount.to_f - 20000) > 0 ? (user.ga1_amount.to_f - 20000) : 0 #可用于兑换钻石币的资金金额
          da1_amount = user.da1_amount.to_f #钻石币余额
          data_arr << [user.id, user.nickname, user.phone, signup_time, signup_source, ga1_amount, usable_exchange_gold, da1_amount]

          ga1_amount_num += ga1_amount #虚拟资金余额合计
          usable_gold_num += usable_exchange_gold #可用于兑换钻石币的资金金额合计
          da1_amount_num += da1_amount #钻石币余额合计
        end

        data_arr << [users.length, '', '', '', '', ga1_amount_num, usable_gold_num, da1_amount_num]
        return data_arr
      end

      #资金变动统计下载
      def change_balance_scv_data params
        data_arr = []
        users = User.user_change_balance_data_hash params
        ga1_num = ga2_num = ga3_num = ga4_num = ga5_num = ga6_num = da1_num = da2_num = da3_num = da4_num = da5_num = 0
        users.each do |user|
          signup_time = user[:user_created_at].strftime('%Y-%m-%d %H:%M')
          signup_source = user[:openid].nil? ? 'h5注册' : '微信注册'
          ga1 = user[:ga_type21].to_f #初始资金
          ga2 = user[:ga_type21].to_f #邀请好友获得虚拟金
          ga3 = user[:ga_type100].to_f + user[:ga_type101].to_f + user[:ga_type102].to_f
          +user[:ga_type103].to_f + user[:ga_type104].to_f #其他方式获得虚拟金
          ga4 = user[:ga_type1].to_f + user[:ga_type2].to_f + user[:ga_type3].to_f + user[:ga_type4].to_f #虚拟盘盈亏
          ga5 = user[:ga_type22].to_f #兑换钻石币消耗的虚拟资金
          ga6 = user[:ga_type50].to_f #其他方式消耗的虚拟资金

          da1 = user[:da_type30].to_f #注册获得钻石币
          da2 = user[:da_type2].to_f #虚拟金兑换的的钻石币
          #其他方式获得的钻石币
          da3 = user[:da_type10].to_f + user[:da_type100].to_f + user[:da_type101].to_f
          +user[:da_type102].to_f + user[:da_type103].to_f + user[:da_type104].to_f
          +user[:da_type31].to_f + user[:da_type32].to_f + user[:da_type33].to_f + user[:da_type34].to_f + user[:da_type36].to_f
          #夺宝消耗的钻石币
          da4 = user[:da_type1].to_f
          #其他方式消耗的钻石币
          da5 = user[:da_type20].to_f + user[:da_type36].to_f
          data_arr << [user[:user_id], user[:nickname], user[:phone], signup_time, signup_source, ga1, ga2, ga3, ga4, ga5, ga6, da1, da2, da3, da4, da5]

          ga1_num += ga1; ga2_num += ga2; ga3_num += ga3; ga4_num += ga4; ga5_num += ga5; ga6_num += ga6
          da1_num += da1; da2_num += da2; da3_num += da3; da4_num += da4; da5_num += da5;

        end
        data_arr << [users.length, '', '', '', '', ga1_num, ga2_num, ga3_num, ga4_num, ga5_num, ga6_num, da1_num,
                     da2_num, da3_num, da4_num, da5_num]
        return data_arr
      end


      #资金月报统计下载
      def month_money_scv_data params
        data_arr = []
        ga1_num = ga2_num = ga3_num = ga4_num = ga5_num = ga6_num = ga7_num = ga8_num = da1_num = da2_num = da3_num = da4_num = da5_num = da6_num = da7_num = 0
        user_data_month = User.user_month_money_data_hash params
        user_data_month.each do |uda|
          month_sum = User.gold_month_sum params.merge({user_id: uda[:user_id]})

          signup_time = uda[:user_created_at].strftime('%Y-%m-%d %H:%M')
          signup_source = uda[:openid].nil? ? 'h5注册' : '微信注册'
          ga1 = month_sum[:ga_begin].to_f #月初资金金额
          ga2 = uda[:ga_type99].to_f #注册赠送资金
          ga3 = uda[:ga_type21].to_f #邀请好友获得虚拟金
          ga4 = uda[:ga_type100].to_f + uda[:ga_type101].to_f + uda[:ga_type102].to_f
          +uda[:ga_type103].to_f + uda[:ga_type104].to_f #其他方式获得虚拟金
          ga5 = uda[:ga_type1].to_f + uda[:ga_type2].to_f + uda[:ga_type3].to_f
          +uda[:ga_type4].to_f #虚拟盘盈亏
          ga6 = uda[:ga_type22].to_f #兑换钻石币消耗的虚拟资金
          ga7 = uda[:ga_type50].to_f #其他方式消耗的虚拟金
          ga8 = month_sum[:ga_end].to_f #月末资金金额
          da1 = month_sum[:da_begin].to_f #月初钻石币余额
          da2 = uda[:da_type30].to_f #注册获得钻石币
          da3 = uda[:da_type2].to_f #虚拟金兑换的钻石币
          #其他方式获得的钻石币
          da4 = uda[:da_type10].to_f + uda[:da_type100].to_f + uda[:da_type101].to_f
          +uda[:da_type102].to_f + uda[:da_type103].to_f + uda[:da_type104].to_f
          +uda[:da_type31].to_f + uda[:da_type32].to_f + uda[:da_type33].to_f + uda[:da_type34].to_f + uda[:da_type36].to_f
          #夺宝消耗的钻石币
          da5 = uda[:da_type1].to_f
          #其他方式消耗的钻石币
          da6 = uda[:da_type20].to_f + uda[:da_type36].to_f
          da7 = month_sum[:da_end].to_f #月末资金金额
          data_arr << [uda[:user_id], uda[:nickname], uda[:phone], signup_time, signup_source, ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8,
                       da1, da2, da3, da4, da5, da6, da7]

          ga1_num += ga1; ga2_num += ga2; ga3_num += ga3; ga4_num += ga4; ga5_num += ga5; ga6_num += ga6; ga7_num += ga7; ga8_num += ga8
          da1_num += da1; da2_num += da2; da3_num += da3; da4_num += da4; da5_num += da5; da6_num += da6; da7_num += da7;
        end

        if !params[:is_web_table].present?
          #网页不显示最后一行统计
          data_arr << [user_data_month.length, '', '', '', '', ga1_num, ga2_num, ga3_num, ga4_num, ga5_num, ga6_num, ga7_num, ga8_num,
                       da1_num, da2_num, da3_num, da4_num, da5_num, da6_num, da7_num]
        end


        return data_arr
      end

    end
  end
end