class ProductTags < ActiveRecord::Migration[5.0]
  def change
    create_table :product_tags do |t|
      t.string :name, comment: '名称'
      t.timestamps
    end
  end
end
