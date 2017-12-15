class AddRankTypeToRankingConfigWins < ActiveRecord::Migration[5.0]
  def change
    add_column :ranking_config_wins, :rank_type, :integer, comment: '领奖类型日:1, 周:2,  月:3, 年:4,5：今日5点半后'
  end
end
