#虚拟金记录表 的account_type类型
#     "系统赠送" => 100,
#     "无分配" => 0,
#     "日排行奖励" => 101,
#     "周排行奖励" => 102,
#     "月排行奖励" => 103,
#     "总排行奖励" => 104,
#     "买入" => 1,
#     "卖出" => 2,
#     "做空" => 3,
#     "平仓" => 4,
#     "买入挂单" => 11,
#     "卖出挂单" => 12,
#     "做空挂单" => 13,
#     "平仓挂单" => 14,
#
#     "买入撤单" => -11,
#     "卖出撤单" => -12,
#     "做空撤单" => -13,
#     "平仓撤单" => -14,
#
#     "邀请注册" => 21,
#     "虚拟金兑换" => 22,
#     "交易宝箱" => 50,

#
#钻币记录表diamond_type类型
#     "夺宝" => 1,
#     "虚拟金兑换" => 2,
#     "钻币礼包" => 10,
#     "0元夺宝奖品兑换" => 20,
#     "系统赠送" => 100,
#     "日排行奖励" => 101,
#     "周排行奖励" => 102,
#     "月排行奖励" => 103,
#     "总排行奖励" => 104,
#     "注册赠送" => 30,

#     "邀请注册赠送" => 31,
#     "福袋中奖分享" => 32,
#     "夺宝中奖分享" => 33,
#     "交易宝箱" => 34,
#     "进贡" => 35,
#     "吃贡" => 36

module Admins
  module Users
    module UserBalanceHelper
      extend ActiveSupport::Concern

      module ClassMethods

        #用户基本情况统计
        def user_info_data params
          conditions, values, per_page = tognji_sql_conditions_helper params
          joins = ["left join (select user_id,sum(total_price) as total_price from diamond_trades GROUP BY user_id) as dia1 on dia1.user_id = users.id",
                   "left join (select user_id,sum(coin_count) as coin_count from coin_bag_lottery_items GROUP BY user_id) as coin on coin.user_id = users.id"]
                   #"left join qrcode_scan_records as qsr on qsr.openid = users.openid",
                   #"left join qrcodes on qrcodes.id = qsr.qrcode_id"]
          User.select('users.*', 'sum(dia1.total_price) as trade_total_price',
                      'sum(coin.coin_count) as coin_bag_coin_count')
              .joins(joins.join('  '))
              .includes(:lottery_order_items, :user_login_logs,
                        :lottery_order_win_items, :share_users,:parent_user)
              .group('users.id')
              .where(conditions.join(' and '), *values)
              .order('created_at asc')
              .paginate(:page => params[:page], :per_page => per_page)
        end


        #资金余额统计hash
        def remain_balance_data_hash params = {}
          conditions, values, per_page = tognji_sql_conditions_helper params
          #left join (select user_id,sum(amount) as amount from gold_accounts GROUP BY user_id) as ga1 on ga1.user_id = users.id


          #统计时间  结束时间
          if params[:tongji_end_datetimepicker].present?
            joins = ["left join (select user_id,sum(amount) as amount from gold_accounts where gold_accounts.created_at <= #{params[:tongji_end_datetimepicker]} GROUP BY user_id) as ga1 on ga1.user_id = users.id",
                     "left join (select user_id,sum(amount) as amount from diamond_accounts where diamond_accounts.created_at <= #{params[:tongji_end_datetimepicker]} GROUP BY user_id) as da1 on da1.user_id = users.id"]
          else
            joins = ["left join (select user_id,sum(amount) as amount from gold_accounts GROUP BY user_id) as ga1 on ga1.user_id = users.id",
                     "left join (select user_id,sum(amount) as amount from diamond_accounts GROUP BY user_id) as da1 on da1.user_id = users.id"]
          end


          user_remain_balance = User.select('users.*', 'sum(ga1.amount) as ga1_amount', 'sum(da1.amount) as da1_amount')
                                    .joins(joins.join('  '))
                                    .group('id')
                                    .order('ga1_amount desc', 'da1_amount desc')
                                    .where(conditions.join(' and '), *values)
                                    .paginate(page: params[:page], per_page: per_page)

          return user_remain_balance
        end

        #资金变动统计
        def user_change_balance_data_hash params
          conditions, values, per_page = tognji_sql_conditions_helper params
          joins = ["left join gold_accounts as ga1 on ga1.user_id = users.id",
                   "left join diamond_accounts as da1 on da1.user_id = users.id"]


          #统计时间  开始时间
          if params[:tongji_start_datetimepicker].present?
            joins[0] = joins[0] + " and ga1.created_at >= '#{params[:tongji_start_datetimepicker]}' "
          end


          #统计时间  结束时间
          if params[:tongji_end_datetimepicker].present?
            joins[1] = joins[1] + " and da1.created_at <='#{params[:tongji_end_datetimepicker]}' "
          end


          #虚拟金
          @user_gold_accounts = User.select('users.*', 'sum(ga1.amount) as ga1_amount',
                                            'ga1.account_type as ga1_account_type')
                                    .joins(joins[0])
                                    .group('id', 'ga1_account_type')
                                    .order('ga1_amount desc', 'id asc',)
                                    .where(conditions.join(' and '), *values)
          #.paginate(page: params[:page], per_page: per_page)


          #钻币
          @user_diamond_accounts = User.select('users.*', 'sum(da1.amount) as da1_amount', 'da1.diamond_type as da1_diamond_type')
                                       .joins(joins[1])
                                       .group('id', 'da1_diamond_type')
                                       .order('da1_amount desc', 'id asc')
                                       .where(conditions.join(' and '), *values)
          #.paginate(page: params[:page], per_page: per_page)

          user_data_month = month_and_change_data_hash_helper @user_gold_accounts, @user_diamond_accounts
          return user_data_month
        end

        #资金月报统计hash
        def user_month_money_data_hash params

          conditions, values, per_page = tognji_sql_conditions_helper params

          joins = ["left join gold_accounts as ga1 on ga1.user_id = users.id",
                   "left join diamond_accounts as da1 on da1.user_id = users.id"]

          #统计时间  结束时间
          if params[:tongji_date].present?
            joins[0] = joins[0] + " and ga1.created_at like'%#{params[:tongji_date]}%' "
            joins[1] = joins[1] + " and da1.created_at like '%#{params[:tongji_date]}%' "
          end


          #虚拟金
          @user_gold_accounts = User.select('users.*', 'sum(ga1.amount) as ga1_amount',
                                            'ga1.account_type as ga1_account_type',
                                            'date_format(ga1.created_at,"%Y-%m") as ga1_created_at')
                                    .joins(joins[0])
                                    .group('id', 'ga1_account_type', 'ga1_created_at')
                                    .order('ga1_amount desc', 'id asc', 'ga1_created_at asc')
                                    .where(conditions.join(' and '), *values)
          #.paginate(page: params[:page], per_page: per_page)


          #钻币
          @user_diamond_accounts = User.select('users.*', 'sum(da1.amount) as da1_amount', 'da1.diamond_type as da1_diamond_type',
                                               'date_format(da1.created_at,"%Y-%m") as da1_created_at')
                                       .joins(joins[1])
                                       .group('id', 'da1_diamond_type', 'da1_created_at').order('da1_amount desc', 'id asc', 'da1_created_at asc')
                                       .where(conditions.join(' and '), *values)
          #.paginate(page: params[:page], per_page: per_page)


          user_data_month = month_and_change_data_hash_helper @user_gold_accounts, @user_diamond_accounts
          return user_data_month
        end


        #中奖订单统计
        def user_orders_data params
          datas = []

          if params[:is_web_table] == true
            lottery_orders = LotteryOrder.includes(:user, :lottery, :lottery_order_items, :address, :product,:pay_records)
                                 .where(is_win: true).paginate(page: params[:page], per_page: 5).order('created_at desc')
          else
            lottery_orders = LotteryOrder.includes(:user, :lottery, :lottery_order_items, :address, :product,:pay_records)
                                 .where(is_win: true).order('created_at desc')
          end

          lor = LotteryOrder.select('user_id','lottery_id','sum(total_count) as total_count','sum(total_price) as total_price')
                    .where(is_win: true).group('user_id','lottery_id')

          lottery_orders.each do |lo|
             address_p=nil;address_n=nil;address_a=nil;pay_money=nil;order_status=nil;buy_count=nil;pay_dia=nil;
            lottery_time = Utils.time_format(lo.lottery.lottery_time) #揭晓时间
            code = lo.code.to_s #订单号
            product_name = lo.product.name #商品名称
            prodcut_price = lo.product.price.to_f #商品价格
            published_at = Utils.time_format(lo.lottery.published_at) #上线时间
            lottery_code = lo.lottery.lottery_code.to_s #抽奖期号
            win_lottery_code = lo.lottery.win_lottery_code #幸运号码
            created_at = Utils.time_format(lo.created_at) #购买时间
            lor.each do |l|
              if l.user_id == lo.user_id && l.lottery_id == lo.lottery_id
                buy_count = l.total_count.to_i #参与人次
                pay_dia = l.total_price.to_f #支付钻石币
              end
            end

            nickname = lo.user.nickname #用户微信
            phone = lo.user.phone #手机号
            if lo.address.present?
              address_n = lo.address.user_name #收货姓名
              address_p = lo.address.phone #收货电话
              address_a = lo.address.address #收货地址
            end


            is_pay = '未支付'
            if lo.pay_records.present?
              is_pay = '已支付' #是否支付邮费
              pay_money = lo.pay_records.first.total_amount.to_f  #支付金额
            end
            case lo.status.to_i
              when -1
                order_status = "已作废"
              when 0
                order_status = "未发货"
              when 1
                order_status = "已发货"
              when 2
                order_status = "已兑换收益"
              when 3
                order_status = "待发货"
            end
            datas << [lottery_time, code, product_name, prodcut_price, published_at, lottery_code, win_lottery_code, created_at,
                      buy_count, pay_dia, nickname, phone, address_n, address_p, address_a, is_pay, pay_money, order_status]

          end


          return datas,lottery_orders
        end

        #钻石币和虚拟的月末和月初 资金金额
        def gold_month_sum params
          if params[:tongji_date].present?
            month_begin_time = (params[:tongji_date] + '-01').to_time.last_month.end_of_month
            month_end_time = (params[:tongji_date] + '-01').to_time.end_of_month
          else
            month_begin_time = Time.now.last_month.end_of_month
            month_end_time = Time.now.end_of_month
          end

          da1_begin_amount = DiamondAccount.where('user_id = ? and created_at <= ?', params[:user_id], month_begin_time).sum('amount')
          da1_end_amount = DiamondAccount.where('user_id = ? and created_at <= ?', params[:user_id], month_end_time).sum('amount')

          ga_begin_amount = GoldAccount.where('user_id = ? and created_at <= ?', params[:user_id], month_begin_time).sum('amount')
          ga_end_amount = GoldAccount.where('user_id = ? and created_at <= ?', params[:user_id], month_end_time).sum('amount')
          month_sum = {ga_begin: ga_begin_amount, ga_end: ga_end_amount, da_begin: da1_begin_amount, da_end: da1_end_amount}

          return month_sum
        end


        #由于清空表导致资金不同恢复数据使用，不对外开放
        def recover_remain_data user_id
          joins = ["left join (select user_id,sum(amount) as amount from gold_accounts GROUP BY user_id) as ga1 on ga1.user_id = users.id",
                   "left join (select user_id,sum(amount) as amount from diamond_accounts GROUP BY user_id) as da1 on da1.user_id = users.id"]


          users = User.select('users.*', 'sum(ga1.amount) as ga1_amount', 'sum(da1.amount) as da1_amount')
                      .joins(joins.join('  '))
                      .group('id')
                      .order('ga1_amount desc', 'da1_amount desc')
                      .where('users.id = ?', user_id)

          user = users[0]
          if user.total_gold != user.ga1_amount
            amount = user.total_gold.to_f - user.ga1_amount.to_f
            avalibale_amount = user.ga1_amount + amount
            GoldAccount.create(user_id: user_id, amount: amount, account_type: 100, available_gold_amount: avalibale_amount, table_type: 'User', table_id: user_id)
          end

          if user.total_diamond_coin != user.da1_amount
            amount = user.total_diamond_coin.to_f - user.da1_amount.to_f
            avalibale_amount = user.da1_amount + amount
            DiamondAccount.create(user_id: user_id, amount: amount, diamond_type: 100, table_type: 'User', table_id: user_id)
          end

        end

        private

        def admin_total_amount_helper amount_arr, conditions_arr
          val = 0.0
          amount_arr.each do |amount|
            if conditions_arr.include? amount[0].to_i
              val += amount[1].to_f
            end
          end
          return val
        end


        #资金月报和资金变动统计查询条件
        def tognji_sql_conditions_helper params
          conditions = []
          values = []
          per_page = 5

          if !params[:is_web_table]
            #下载所有符合条件的用户
            per_page = User.count
          end

          if params[:user_ids]
            conditions << 'users.id in (?)'
            values << params[:user_ids]
          end

          #用户名

          if params[:nickname].present?
            conditions << 'users.nickname like (?)'
            values << "%#{params[:nickname]}%"
          end

          #用户注册时间查询  开始
          if params[:csv_start_datetimepicker].present?
            conditions << 'users.created_at >= ?'
            values << params[:csv_start_datetimepicker]

          end

          #用户注册时间查询 结束
          if params[:csv_end_datetimepicker].present?
            conditions << 'users.created_at <= ?'
            values << params[:csv_end_datetimepicker]
          end


          if params[:user_source].present?
            case params[:user_source].to_i
              when 2
                #微信注册
                conditions << 'users.openid is not null'
              when 3
                conditions << 'users.openid is  null'
            end

          end

          return conditions, values, per_page

        end


        def month_and_change_data_hash_helper user_gold_accounts, user_diamond_accounts
          user_data_hash = []
          user_ids = []
          user_gold_accounts.each do |uga|
            if user_ids.include?(uga.id)
              index = user_ids.index(uga.id)
              user_data_hash[index] = user_data_hash[index].merge({"ga_type#{uga.ga1_account_type}": uga.ga1_amount.to_f})
            else
              user_ids << uga.id
              user_data_hash << {user_id: uga.id, nickname: uga.nickname, phone: uga.phone, openid: uga.openid, user_created_at: uga.created_at,
                                 "ga_type#{uga.ga1_account_type}": uga.ga1_amount.to_f}
            end

          end

          user_diamond_accounts.each do |uda|
            if user_ids.include?(uda.id)
              index = user_ids.index(uda.id)
              user_data_hash[index] = user_data_hash[index].merge({"da_type#{uda.da1_diamond_type}": uda.da1_amount.to_f})
            else
              user_ids << uda.id
              user_data_hash << {user_id: uda.id, openid: uda.openid, user_created_at: uda.created_at,
                                 "da_type#{uda.da1_diamond_type}": uda.da1_amount.to_f}
            end

          end

          return user_data_hash
        end


      end


    end
  end
end
