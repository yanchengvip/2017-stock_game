class AddIntervalToProductAndLottery < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :interval, :integer, default: 0, comment: '限制上期中奖用户的中奖天数间隔'
    add_column :products, :lottery_percent, :integer, default: 1, comment: '用户抽奖次数的百分比1-100'
    add_column :lotteries, :interval, :integer, default: 0, comment: '限制上期中奖用户的中奖天数间隔'
    add_column :lotteries, :lottery_percent, :integer, default: 1, comment: '用户抽奖次数的百分比1-100'
  end
end
