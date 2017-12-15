class AddIndexToRankingConfigWins < ActiveRecord::Migration[5.0]
  def change
    add_column :ranking_config_wins, :day, :string, comment: '日期'
  end
end
