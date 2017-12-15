class AddProductTypeToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products,:product_type,:integer,default: 0,comment: '产品类型0:无类型,1:夺宝产品,2:福袋产品'
  end
end
