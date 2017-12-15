class CreateShareConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :share_configs do |t|
      t.string :title
      t.string :desc
      t.string :img_url
      t.string :link_url
      t.integer :user_id

      t.timestamps
    end
  end
end
