class Admins::RankingConfigItemsController < Admins::ApplicationController
  #before_action :set_ranking_config_item, only: [:show, :edit, :update, :destroy]


  private

  def set_ranking_config_item
    @ranking_config_item = RankingConfigItem.find(params[:id])
  end


  def ranking_config_item_params
    params.require(:ranking_config_item).permit(:ranking_config_id, :table_type, :table_id, :price, :prize_type)
  end
end
