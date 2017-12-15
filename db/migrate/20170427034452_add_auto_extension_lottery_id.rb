class AddAutoExtensionLotteryId < ActiveRecord::Migration[5.0]
  def change
    add_column :lotteries,:auto_extension_lottery_id,:integer,default: -1,comment: '自动延续时父级lotteryID'
  end
end
