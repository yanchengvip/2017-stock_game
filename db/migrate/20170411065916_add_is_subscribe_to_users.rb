class AddIsSubscribeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_subscribe, :boolean, default: false, comment: '是否已关注钻石大富翁公众号'
  end
end
