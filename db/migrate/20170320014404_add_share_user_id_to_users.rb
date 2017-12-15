class AddShareUserIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :share_user_id, :integer, default: 0, comment: "邀请用户id"
  end
end
