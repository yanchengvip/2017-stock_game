class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products, comment: "商品表" do |t|
      t.string :name, comment: "名称"
      t.text :desc, comment: "简述"
      t.decimal :price, precision: 10, scale: 2, default: 0, comment: "价格"
      t.integer :inventory_count, default: 0, comment: "库存"
      t.string :detail_url, comment: "详情地址"
      t.string :head_image, comment: "大图"
      t.boolean :is_published, default: true, comment: "是否发布"
      t.integer :user_id, default: 0, comment: "用户id"

      t.timestamps
    end
  end
end
