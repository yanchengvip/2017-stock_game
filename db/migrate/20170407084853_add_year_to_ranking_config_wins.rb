class AddYearToRankingConfigWins < ActiveRecord::Migration[5.0]
  def change
    add_column :ranking_config_wins, :week, :integer, default: 0, comment: '周'
    add_column :ranking_config_wins, :month, :integer, default: 0, comment: '月'
    add_column :ranking_config_wins, :year, :integer, default: 0, comment: '年'

    add_index :ranking_config_wins, [:year, :month], name: 'rank_year_month', using: :btree
    add_index :ranking_config_wins, [:year, :week], name: 'rank_year_week', using: :btree
  end
end
