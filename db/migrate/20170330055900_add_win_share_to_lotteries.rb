class AddWinShareToLotteries < ActiveRecord::Migration[5.0]
  def change
    add_column :lotteries, :win_share, :boolean, default: false,  comment: "是否分享"
  end
end
