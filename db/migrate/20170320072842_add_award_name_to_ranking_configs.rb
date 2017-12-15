class AddAwardNameToRankingConfigs < ActiveRecord::Migration[5.0]
  def change
    add_column :ranking_configs,:award_name,:string,comment: "奖励的名称"
  end
end
