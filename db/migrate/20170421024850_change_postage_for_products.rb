class ChangePostageForProducts < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :postage, :decimal,precision: 10,scale: 2, default: 0, comment: '商品邮费'
  end
end
