class AddFollowersCountAndFollowingCountToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :following_count, :integer, default:0, comment: "自己关注的人数"
    add_column :users, :followers_count, :integer, default:0, comment: "关注自己的人数"
  end
end
