class AddIsUsingToRankingConfigs < ActiveRecord::Migration[5.0]
  def change
    add_column :ranking_configs,:status,:integer,default: 1, comment: '-1:删除，1:使用中'
  end
end
