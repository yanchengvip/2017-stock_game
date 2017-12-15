class Admins::RankingConfigWinsController < Admins::ApplicationController
  #before_action :set_ranking_config_win, only: [:show, :edit, :update, :destroy]
  before_action :ranking_side_menus
  before_action :set_earning_menu_active, only: [:earning_record]
  before_action :set_rate_menu_active, only: [:rate_record]

  #收益领奖记录
  def earning_record
    @rcw_orders = RankingConfigWinOrder.find_ranking_orders 1,params

  end

  #收益率领奖记录
  def rate_record
    @rcw_orders = RankingConfigWinOrder.find_ranking_orders 2,params
    # @rcw_orders = RankingConfigWinOrder.includes(:ranking_config_win, :ranking_config_item, :user, :ranking_config)
    #                   .where('ranking_configs.ranking_type': 2)
    #                   .paginate(:page => params[:page], :per_page => 20)

    render template: 'admins/ranking_config_wins/earning_record'
  end


  private

  def set_ranking_config_win
    @ranking_config_win = RankingConfigWin.find(params[:id])
  end

  def set_rate_menu_active
    @menu_active = '收益率领奖记录'
  end

  def set_earning_menu_active
    @menu_active = '收益领奖记录'
  end


  def ranking_config_win_params
    params.require(:ranking_config_win).permit(:user_id, :lottery_time, :ranking_config_id)
  end
end
