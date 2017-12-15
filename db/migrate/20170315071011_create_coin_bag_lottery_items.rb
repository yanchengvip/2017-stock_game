class CreateCoinBagLotteryItems < ActiveRecord::Migration[5.0]
  def change
    create_table :coin_bag_lottery_items do |t|
      t.integer :coin_bag_lottery_id,comment: '钻石礼包抽奖ID'
      t.integer :coin_bag_id,comment: '钻石礼包ID'
      t.integer :user_id,comment: '抽奖用户ID'
      t.string :request_ip,comment: '抽奖用户ip'
      t.integer :coin_count,defalut: 0,comment: '抽到的钻石币数量'

      t.timestamps
    end
  end
end
