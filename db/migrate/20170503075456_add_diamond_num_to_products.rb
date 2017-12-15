class AddDiamondNumToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :diamond_num, :integer, default: 0, comment: '赠送钻币数量'
    add_column :products, :product_second_type, :integer, default: 0, comment: '商品的二级类型; 0:无,1:赠送钻币的夺宝商品'
  end
end
