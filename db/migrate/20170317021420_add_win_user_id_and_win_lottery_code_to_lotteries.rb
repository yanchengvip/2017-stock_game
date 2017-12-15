class AddWinUserIdAndWinLotteryCodeToLotteries < ActiveRecord::Migration[5.0]
  def change
    add_column :lotteries, :win_user_id, :integer, default: 0, comment: "中奖用户id"
    add_column :lotteries, :win_lottery_code, :string, comment: "中奖号码"
  end
end
