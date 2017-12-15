class ChangeIsSubscribeUsers < ActiveRecord::Migration[5.0]
  def change  
    remove_column :users, :is_subscribe
    add_column :users, :subscribe_status, :integer, default: 0, comment: '是否已关注钻石大富翁公众号:0未关注、1已关注、-1已取消关注'
  end  
end
