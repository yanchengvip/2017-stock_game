class AddShareUserGivedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :share_user_gived, :boolean, default: false, comment: '分享用户是否已赠送钻石币'
  end
end
