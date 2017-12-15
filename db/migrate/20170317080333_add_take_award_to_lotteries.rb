class AddTakeAwardToLotteries < ActiveRecord::Migration[5.0]
  def change
    add_column :lotteries, :take_award, :boolean, default:false, comment: "是否领奖"
  end
end
