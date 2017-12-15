class Admins::HomesController < Admins::ApplicationController

  def index
    @users_num = User.count
    @trade_users_num = DiamondTrade.select(:user_id).distinct.count(:user_id) #已交易用户数
    @diamond_coin_num = User.sum('total_diamond_coin') #持有钻石币总数
    @padm = (@diamond_coin_num / @users_num).round if @users_num > 0 #人均钻石币数量
    @total_profit = DiamondTrade.sum(:profit) #总收益
    @patp = (@total_profit / @users_num).round if @users_num > 0 #人均收益

    @yt_lo_num = tj_num_helper 'LotteryOrder'#昨日夺宝人数
    @yt_sign_num = tj_num_helper 'DaySign'#昨日签到人数
    @yt_trade_num = tj_num_helper 'DiamondTrade' #昨日模拟盘交易人数
  end



  def tj_more
    @title = params[:title]
    @objs = tj_more_helper params[:model]
  end

  private

  def tj_num_helper obj_str
    yt_b = (Date.today - 1).beginning_of_day
    yt_e = (Date.today - 1).end_of_day
    obj_str.constantize.select(:user_id).where('created_at >= ? and created_at <= ? ', yt_b, yt_e).distinct.count(:user_id)
  end

  def tj_more_helper table_str
    table_str.classify.constantize.paginate_by_sql('SELECT count( DISTINCT user_id ) as count,date_format(created_at,"%Y-%m-%d") as date FROM ' + table_str +' GROUP BY date order by date desc',
                                        page: params[:page],per_page: 20)
  end
end
