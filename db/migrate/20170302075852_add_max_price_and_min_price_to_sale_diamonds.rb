class AddMaxPriceAndMinPriceToSaleDiamonds < ActiveRecord::Migration[5.0]
  def change
    add_column :sale_diamonds, :max_price, :decimal, precision: 10, scale: 2, default: 0, comment: "最高价"
    add_column :sale_diamonds, :min_price, :decimal, precision: 10, scale: 2, default: 0, comment: "最低价"
  end
end
