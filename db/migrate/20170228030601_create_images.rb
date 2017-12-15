class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.string :url, comment: "用户id"
      t.string :name, comment: "用户id"
      t.string :content_size, comment: "大小"
      t.integer :table_id, comment: "table_id"
      t.string :table_type, comment: "table_type"

      t.timestamps
    end
  end
end
