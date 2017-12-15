class CreateRankingConfigItems < ActiveRecord::Migration[5.0]
  def change
    create_table :ranking_config_items do |t|
      t.integer :ranking_config_id
      t.string :table_type
      t.string :table_id
      t.string :price
      t.integer :prize_type,default:1,comment: '奖品类型：1:无,2虚拟资金3:钻石币4:夺宝商品5:分享福袋6:钻石礼包7:现金'

      t.timestamps
    end
  end
end
