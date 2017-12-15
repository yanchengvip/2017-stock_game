class AddRoleToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :role, :string, default: 1, comment: '用户角色 1:普通用户,3:内测用户'
  end
end
