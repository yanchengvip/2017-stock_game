class AddTimeToMicriDiamondAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :micro_diamond_accounts, :created_at, :datetime
    add_column :micro_diamond_accounts, :updated_at, :datetime
  end
end
