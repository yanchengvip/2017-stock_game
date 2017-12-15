class AddChestFirstGivedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :chest_first_gived, :boolean, default: false, comment: '宝箱用户首次是否已赠送60钻币'
  end
end
