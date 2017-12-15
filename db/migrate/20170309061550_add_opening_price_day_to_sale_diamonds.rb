class AddOpeningPriceDayToSaleDiamonds < ActiveRecord::Migration[5.0]
  def change
    add_column :sale_diamonds, :opening_price_day, :string, comment: "开盘价日期"
  end
end
