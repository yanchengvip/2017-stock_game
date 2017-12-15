class AddTableTypeAndTableIdToDiamondAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :diamond_accounts, :table_type, :string
    add_column :diamond_accounts, :table_id, :integer
  end
end
