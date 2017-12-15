class AddYesterdayClosePirceToSaleDiamonds < ActiveRecord::Migration[5.0]
  def change
    add_column :sale_diamonds, :yesterday_close_pirce, :decimal, precision: 10, scale: 2, default: 0, comment: "收盘价"
  end
end
