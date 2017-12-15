class AddRakingOrderIdToRankingConfigWins < ActiveRecord::Migration[5.0]
  def change
      remove_column :ranking_config_wins,:lottery_order_id
  end
end
