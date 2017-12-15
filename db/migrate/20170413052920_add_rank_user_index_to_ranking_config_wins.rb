class AddRankUserIndexToRankingConfigWins < ActiveRecord::Migration[5.0]
  def change
    add_index :ranking_config_wins, [:user_id, :ranking_config_id, :year, :week, :rank_type, :date_type, :day], name: 'rank_user_index', unique: true
  end
end
