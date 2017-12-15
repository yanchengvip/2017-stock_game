class RemoveRemainCoinCountLockVersionToCoinBags < ActiveRecord::Migration[5.0]
  def change
    remove_column :coin_bags, :remain_coin_count, :integer
    remove_column :coin_bags, :coin_count_groups, :integer
    remove_column :coin_bags, :lock_version, :integer
  end
end
