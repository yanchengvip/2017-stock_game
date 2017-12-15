class AddStatusToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :status, :integer, comment: "用户状态， 0 正常， -1冻结", default: 0
  end
end
