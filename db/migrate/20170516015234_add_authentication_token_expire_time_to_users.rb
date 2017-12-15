class AddAuthenticationTokenExpireTimeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :authentication_token_expire_time, :datetime, comment: "token 过期时间"
  end
end
