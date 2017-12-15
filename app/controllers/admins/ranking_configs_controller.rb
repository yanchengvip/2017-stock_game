class Admins::RankingConfigsController < Admins::ApplicationController
  #before_action :set_ranking_config, only: [:show, :edit, :update, :destroy]
  before_action :ranking_side_menus
  before_action :set_earning_manage_menu_active, only: [:earning_manage]
  before_action :set_rate_manage_menu_active, only: [:rate_manage]


  #收益奖品设置
  def earning_manage
    @day_list = RankingConfig.where(date_type: 1, ranking_type: 1, status: 1).order(ranking: :asc)
    @week_list = RankingConfig.where(date_type: 2, ranking_type: 1, status: 1).order(ranking: :asc)
    @month_list = RankingConfig.where(date_type: 3, ranking_type: 1, status: 1).order(ranking: :asc)
    @year_list = RankingConfig.where(date_type: 4, ranking_type: 1, status: 1).order(ranking: :asc)
  end


  #收益率奖品设置
  def rate_manage
    @day_list = RankingConfig.where(date_type: 1, ranking_type: 2, status: 1).order(ranking: :asc)
    @week_list = RankingConfig.where(date_type: 2, ranking_type: 2, status: 1).order(ranking: :asc)
    @month_list = RankingConfig.where(date_type: 3, ranking_type: 2, status: 1).order(ranking: :asc)
    @year_list = RankingConfig.where(date_type: 4, ranking_type: 2, status: 1).order(ranking: :asc)
  end

  #奖品设置页面
  def award_manage
    if params[:ranking_type] == '1'
      @menu_active = '收益奖品设置'
    end
    if params[:ranking_type] == '2'
      @menu_active = '收益率奖品设置'
    end
    @ranking_config = RankingConfig.includes(:ranking_config_items).find(params[:id])
    @ranking_config.ranking_config_items.each do |rci|

      @virtual_money_v = rci.price if rci.prize_type == 2 #虚拟资金
      @diamond_money_v = rci.price if rci.prize_type == 3 #钻石币
      @real_money_v = rci.price if rci.prize_type == 7 #现金
      @lottery_product_v = rci.table_id if rci.prize_type == 4
      @lucky_bag_v = rci.table_id if rci.prize_type == 5

    end

    @lottery_products = Product.where('inventory_count > ? and is_published = ? and product_type = ?', 0, true, 1)
    @lucky_bags = Product.where('inventory_count > ? and is_published = ? and product_type = ?', 0, true, 2)
  end


  def award_manage_save
    ranking_config = RankingConfig.includes(:ranking_config_items).find(params[:ranking_config_id])
    ranking_config.award_manage_save params

    case params[:ranking_type].to_i
      when 1
        redirect_to '/admins/ranking_configs/earning_manage', notice: '成功添加收益奖品' and return
      when 2
        redirect_to '/admins/ranking_configs/rate_manage', notice: '成功添加收益率奖品' and return
      else
        redirect_to :back, notice: '成功添加收益率奖品' and return
    end

  end

  #创建名次
  def create
    rc = RankingConfig.where(ranking_config_params.merge({status: 1}))
    rc_num = RankingConfig.where(date_type: params[:date_type], ranking_type: params[:ranking_type], status: 1).count
    to_url = params[:from_url]
    #相同规则下的奖品名次ranking不能重复
    if rc.present?
      redirect_to "/admins/ranking_configs/#{to_url}", notice: '创建失败！名次已经存在了，不能重复创建！' and return
    end
    if rc_num >= 10
      redirect_to "/admins/ranking_configs/#{to_url}", notice: '创建失败！每个奖项最多创建10个名次！' and return
    end
    ranking_config = RankingConfig.new(ranking_config_params.merge(award_name: '无奖励'))
    ranking_config.save
    redirect_to "/admins/ranking_configs/#{to_url}"
  end


  private

  def set_ranking_config
    @ranking_config = RankingConfig.find(params[:id])
  end

  def ranking_config_params
    params.permit(:ranking, :date_type, :ranking_type, :status)
  end


  def set_earning_manage_menu_active
    @menu_active = '收益奖品设置'
  end

  def set_rate_manage_menu_active
    @menu_active = '收益率奖品设置'
  end

end
