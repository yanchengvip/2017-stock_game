class CreateCoinBags < ActiveRecord::Migration[5.0]
  def change
    create_table :coin_bags do |t|
      t.integer :coin_count,default: 0 ,comment: '钻石币总数量'
      t.integer :person_count,default: 0 ,comment: '所需抽奖总人数'
      t.integer :remain_coin_count,default: 0 ,comment: '剩余钻石币数量'
      t.string :coin_count_groups,default: 0 ,comment: '钻石币抽奖份，份量等于总人数，之和等于石币总数量'
      t.datetime :end_time,comment: '有效期'
      t.boolean :is_published,default: false, comment: '是否发布'
      t.integer :lock_version,default: 0 , comment: '乐观锁使用字段'

      t.timestamps
    end
  end
end
