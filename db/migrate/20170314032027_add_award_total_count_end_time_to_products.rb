class AddAwardTotalCountEndTimeToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products,:award,:string,comment: '福袋的中奖奖品'
    add_column :products,:total_count,:integer,default: 0,comment: '福袋分享后需要的抽奖总人数'
    add_column :products,:end_time,:datetime,comment: '福袋有效期'
    add_column :lotteries,:user_id,:integer,comment: '拥有福袋的用户'
  end
end
