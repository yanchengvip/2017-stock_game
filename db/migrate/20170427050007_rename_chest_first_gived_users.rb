class RenameChestFirstGivedUsers < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :chest_first_gived, :is_fresh
  end
end
