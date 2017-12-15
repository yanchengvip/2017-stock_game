class AddProgressToLotteries < ActiveRecord::Migration[5.0]
  def change
    add_column :lotteries, :progress, :decimal, precision: 10, scale: 5, default:0, comment: "进度"
    add_column :lotteries, :product_price, :decimal, precision: 10, scale: 2, default:0, comment: "商品价格"
  end
end
