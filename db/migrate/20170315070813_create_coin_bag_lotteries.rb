class CreateCoinBagLotteries < ActiveRecord::Migration[5.0]
  def change
    create_table :coin_bag_lotteries do |t|
      t.integer :coin_bag_id,comment: '钻石礼包ID'
      t.integer :user_id,comment: '分发给用户的ID'
      t.string :share_code,comment: '分享code'

      t.timestamps
    end
  end
end
