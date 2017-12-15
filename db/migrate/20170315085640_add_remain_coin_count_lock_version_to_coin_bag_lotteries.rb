class AddRemainCoinCountLockVersionToCoinBagLotteries < ActiveRecord::Migration[5.0]
  def change
    add_column :coin_bag_lotteries,:coin_count,:integer,default:0, comment: '钻石币总数量'
    add_column :coin_bag_lotteries,:person_count,:integer,default:0, comment: '所需抽奖总人数'
    add_column :coin_bag_lotteries,:remain_coin_count,:integer,default:0, comment: '剩余钻石币数量'
    add_column :coin_bag_lotteries,:coin_count_groups,:text, comment: '钻石币数量随机分组'
    add_column :coin_bag_lotteries,:lock_version,:integer,default: 0 , comment: '乐观锁使用字段'
    add_column :coin_bag_lotteries,:end_time,:datetime,comment: '有效期'
  end
end
