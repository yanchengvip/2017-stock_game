class AddProductSortToProductTag < ActiveRecord::Migration[5.0]
  def change
    add_column :product_tags, :sort, :integer, default: 0, comment: '排序'
  end
end
