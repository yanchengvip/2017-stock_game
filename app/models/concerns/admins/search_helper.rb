module Admins
  module SearchHelper
    extend ActiveSupport::Concern

    #类方法
    module ClassMethods
      #后台查询用户
      def admin_find_users params
        conditions = []
        values = []
        if params[:name_or_phone].present?

          conditions << 'nickname like ? or phone like ?'
          values << "%#{params[:name_or_phone]}%"
          values << "%#{params[:name_or_phone]}%"
        end

        User.where(conditions.join(' and '), *values)
            .paginate(:page => params[:page], :per_page => 20)


      end


      #竞赛排名领奖订单查询
      def find_ranking_orders ranking_type, params

        joins = ['inner join ranking_config_items as rci on rci.id = ranking_config_win_orders.ranking_config_item_id',
                 'inner join ranking_configs as rc on rc.id = rci.ranking_config_id']
        conditions = ['rc.ranking_type = ?']
        values = [ranking_type]
        if params[:lottery_time].present?
          lt = params[:lottery_time].to_time
          conditions << 'ranking_config_win_orders.created_at >= ? and ranking_config_win_orders.created_at <= ?'
          values << lt.beginning_of_day
          values << lt.end_of_day
        end

        if params[:user_name].present?
          joins << 'right join users as u on u.id = ranking_config_win_orders.user_id'
          conditions << 'u.nickname like ?'
          values << "%#{params[:user_name]}%"
        end

        if params[:user_phone].present?
          if !joins.include? ('right join users as u on u.id = ranking_config_win_orders.user_id')
            joins << 'right join users as u on u.id = ranking_config_win_orders.user_id'
          end
          conditions << 'u.phone = ?'
          values << params[:user_phone]

        end

        if params[:award_name].present?
          # joins << 'right join ranking_config_items as rci on rci.id = ranking_config_win_orders.ranking_config_item_id'
          joins << 'right join products as pro on pro.id = rci.table_id'
          conditions << 'pro.name like ?'
          values << "%#{params[:award_name]}%"
        end

        if params[:date_type].present?
          # joins << 'right join ranking_config_wins as rcw on rcw.id = ranking_config_win_orders.ranking_config_win_id'
          # joins << 'right join ranking_configs as rc on rc.id = rcw.ranking_config_id'
          if params[:date_type] == '0'
            conditions << 'rc.date_type in (?) '

            values << '1,2,3,4'
          else
            conditions << 'rc.date_type = ?'
            values << params[:date_type].to_i
          end

        end

        if params[:wuliu_status].present?
          if params[:wuliu_status] == '2'
            conditions << 'ranking_config_win_orders.status in (?)'
            values << '0,1'

          else
            conditions << 'ranking_config_win_orders.status = ?'
            values << params[:wuliu_status]
          end

        end

        @rcw_orders = RankingConfigWinOrder.includes(:ranking_config_win, :ranking_config_item, :user, :ranking_config)
                          .joins(joins.join(' '))
                          .where(conditions.join(' and '), *values)
                          .paginate(:page => params[:page], :per_page => 20)

      end


      #夺宝列表查询
      def find_lottery params
        joins = ['left join products on products.id = lotteries.product_id']
        conditions = []
        values = []
        if params[:product_type].present?
          conditions = ['products.product_type = ?']
          values << params[:product_type].to_i
        end

        if params[:published_at].present?
          pa = params[:published_at].to_time
          conditions << 'published_at >= ? and published_at <=? '
          values << pa.beginning_of_day
          values << pa.end_of_day
        end

        if params[:lottery_code].present?
          conditions << 'lottery_code like ? '
          values << "%#{params[:lottery_code]}%"
        end

        if params[:product_name].present?
          conditions << 'product_name like ?'
          values << "%#{params[:product_name]}%"
        end

        if params[:user_name].present?
          joins << 'left join users on users.id = lotteries.user_id'
          conditions << 'users.nickname like ?'
          values << "%#{params[:user_name]}%"
        end

        if params[:auto_extension_status].present? && [1,2].include?(params[:auto_extension_status].to_i)
          conditions << 'auto_extension_status= ? '
          values << "#{params[:auto_extension_status]}"
        end

        @lotteries = Lottery.includes(:product).where(conditions.join(' and '), *values)
                         .joins(joins.join(' '))
                         .order(sort: :desc, published_at: :desc)
                         .paginate(:page => params[:page], :per_page => 30)
      end

      #查询夺宝/福袋 中奖订单
      def find_lottery_orders params
        joins = ['left join lotteries as lottery on lottery.id = lottery_orders.lottery_id',
                 'left join products on products.id = lottery.product_id']
        conditions = ['products.product_type = ?']
        values = [1]

        if params[:created_at].present?
          pa = params[:created_at].to_time
          conditions << 'lottery_orders.created_at >= ? and lottery_orders.created_at <=? '
          values << pa.beginning_of_day
          values << pa.end_of_day
        end

        if params[:lottery_code].present?
          conditions << 'lottery.lottery_code like ?'
          values << "%#{params[:lottery_code]}%"
        end

        if params[:purchaser].present?
          joins << 'left join users on users.id = lottery_orders.user_id'
          conditions << 'users.nickname like ?'
          values << "%#{params[:purchaser]}%"
        end

        if params[:order_status] == '100' || params[:order_status].nil?
          conditions << "lottery_orders.status in ('-1','0','1','2','3')"
          #values << '0,1,2,3'
        else
          conditions << 'lottery_orders.status = ?'
          values << params[:order_status]
        end

        @lottery_orders = LotteryOrder.includes(:product, :lottery)
                              .joins(joins.join('  '))
                              .where(conditions.join(' and '), *values)
                              .where(is_win: true)
                              .order(created_at: :desc)
                              .paginate(:page => params[:page], :per_page => 20)
      end


      #商品列表的查询
      def find_products params
        conditions = []
        values = []
        if params[:product_type].present?
          conditions << 'products.product_type = ?'
          values << params[:product_type].to_i
        end

        if params[:product_name].present?
          conditions << 'products.name like ?'
          values << "%#{params[:product_name]}%"
        end

        @products = Product.where(conditions.join(' and '), *values)
                        .order(created_at: :desc)
                        .paginate(:page => params[:page], :per_page => 30)

      end


      #福袋中奖记录查询
      def find_lottery_order_items params
        conditions = []
        values = []
        joins = ['left join lotteries as lottery on lottery.id = lottery_order_items.lottery_id',
                 'left join products on products.id = lottery.product_id',
                 'left join lottery_orders  on lottery_orders.id = lottery_order_items.lottery_order_id']
        if params[:product_type].present?
          conditions = ['products.product_type = ?']
          values << params[:product_type].to_i
        end

        if params[:created_at].present?
          pa = params[:created_at].to_time
          conditions << 'lottery_order_items.created_at >= ? and lottery_order_items.created_at <=? '
          values << pa.beginning_of_day
          values << pa.end_of_day
        end

        if params[:lottery_code].present?
          conditions << 'lottery_order_items.lottery_code like (?)'
          values << "%#{params[:lottery_code]}%"
        end

        if params[:user_name].present?
          joins << 'left join users on users.id = lottery_order_items.user_id '
          conditions << 'users.nickname like ?'
          values << "%#{params[:user_name]}%"
        end


        if params[:order_status] == '100' || params[:order_status].nil?
          joins << ''
          conditions << "lottery_orders.status in ('-1','0','1','3')"
          #values << '0,1,2'
        else
          conditions << 'lottery_orders.status = ?'
          values << params[:order_status].to_i
        end


        @lottery_order_items = LotteryOrderItem.includes(:user, :product, :lottery, :lottery_order)
                                   .joins(joins.join(' '))
                                   .where(conditions.join(' and '), *values)
                                   .where(is_win: true)
                                   .order(created_at: :desc)
                                   .paginate(:page => params[:page], :per_page => 20)

      end


      #查找钻石包
      def find_coin_bags params
        conditions = []
        values = []
        if params[:coin_count].present?
          conditions << 'coin_bags.coin_count = ? '
          values << params[:coin_count]
        end

        if params[:end_time].present?
          pa = params[:end_time].to_time
          conditions << 'coin_bags.end_time >= ? and coin_bags.end_time <=? '
          values << pa.beginning_of_day
          values << pa.end_of_day

        end

        @coin_bags = CoinBag.where(conditions.join(' and '), *values)
                         .order(end_time: :desc)
                         .paginate(:page => params[:page], :per_page => 20)

      end
    end


  end

end
