class AddNumAAndNumBToLotteries < ActiveRecord::Migration[5.0]
  def change
    add_column :lotteries, :num_a, :string, default:"", comment: "开奖参数"
    add_column :lotteries, :num_b, :string, default:"", comment: "开奖参数"
  end
end
