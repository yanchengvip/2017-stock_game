class AddLotteryEndTimeToLotteries < ActiveRecord::Migration[5.0]
  def change
    add_column :lotteries, :lottery_end_time, :datetime, comment: "抽奖结束时间"
  end
end
