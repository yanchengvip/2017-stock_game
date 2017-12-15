class AddLotteryOrderIdLotteryIdToRankingConfigWin < ActiveRecord::Migration[5.0]
  def change
     add_column :ranking_config_wins, :lottery_order_id,:integer,comment: '保存领奖后的lottery_order的ID'
     add_column :ranking_config_wins, :lottery_id,:integer,comment: '保存福袋领奖后的lottery的ID'
  end
end
