class ChangeColumnUserIdRankingConfigWins < ActiveRecord::Migration[5.0]
  def up  
    change_column :ranking_config_wins, :user_id, :integer, comment: '领奖用户'
  end  
  
  def down  
    change_column :ranking_config_wins,  :user_id, :string 
  end
end
