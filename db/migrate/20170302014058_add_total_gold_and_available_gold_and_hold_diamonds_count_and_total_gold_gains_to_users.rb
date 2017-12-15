class AddTotalGoldAndAvailableGoldAndHoldDiamondsCountAndTotalGoldGainsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :total_gold, :decimal, precision: 10, scale: 2, default: 20000, comment: "总虚拟金"
    add_column :users, :available_gold, :decimal, precision: 10, scale: 2, default: 20000, comment: "可用虚拟金"
    add_column :users, :hold_diamonds_count, :integer, default: 0, comment: "持有钻石数量"
    add_column :users, :total_gold_gains, :decimal, precision: 10, scale: 2, default: 0, comment: "总收益"
  end
end
