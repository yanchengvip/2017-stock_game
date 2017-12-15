class AddProductTagIdToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :product_tag_id, :integer, default: 0, comment: 'ProductTagID'
  end
end
