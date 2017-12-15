class ChangeLotteryPercentToProducts < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :lottery_percent, :decimal,precision: 10,scale: 3, default: 0.05, comment: '用户抽奖次数的百分比0-1'
    change_column :lotteries, :lottery_percent, :decimal,precision: 10,scale: 3, default: 0.05, comment: '用户抽奖次数的百分比0-1'
  end
end
