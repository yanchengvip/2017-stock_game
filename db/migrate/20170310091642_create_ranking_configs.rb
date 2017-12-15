class CreateRankingConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :ranking_configs do |t|
      t.integer :ranking,default: 0,comment: '名次:1..10'
      t.integer :date_type,default: 0,comment: '无分配:0,日:1, 周:2,  月:3, 年:4'
      t.integer :ranking_type,default: 0,comment: '0:无分类,1:收益,2:收益率'

      t.timestamps
    end
  end
end
