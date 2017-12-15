class AddLotteryCodeAndAwardToLottery < ActiveRecord::Migration[5.0]
  def change
    add_column :lotteries,:award,:string,comment: '奖品名称'
    add_column :lotteries,:lottery_code,:string,comment: '抽奖期号'
    add_column :lotteries,:end_time,:datetime,comment:'抽奖结束日期'
  end
end
