class AddColumnsToGoldGainsHistories < ActiveRecord::Migration[5.0]
  def change
    add_column :gold_gains_histories, :hold_diamonds_gains, :decimal, precision: 10, scale: 2, comment: "持仓钻石收益", default: 0
    add_column :gold_gains_histories, :trade_diamonds_gains, :decimal, precision: 10, scale: 2, comment: "卖出钻石收益", default: 0
    add_column :gold_gains_histories, :close_gains,  :decimal, precision: 10, scale: 2, comment: "平仓收益", default: 0
    add_column :gold_gains_histories, :short_gains, :decimal, precision: 10, scale: 2, comment: "做空收益", default: 0
  end
end
