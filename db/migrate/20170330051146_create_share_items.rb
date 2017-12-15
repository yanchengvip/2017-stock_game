class CreateShareItems < ActiveRecord::Migration[5.0]
  def change
    create_table :share_items, comment: "分享记录"  do |t|
      t.integer :user_id, comment: "分享用户id"
      t.string :controller, comment: "分享controller"
      t.string :action, comment: "分享action"
      t.integer :share_id, comment: "分享share_id", default: 0
      t.timestamps
    end
  end
end
