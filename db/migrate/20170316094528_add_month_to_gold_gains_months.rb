class AddMonthToGoldGainsMonths < ActiveRecord::Migration[5.0]
  def change
    add_column :gold_gains_months, :month, :integer, comment: '月份'
    add_column :gold_gains_months, :year, :integer, comment: '年份'

    add_index :gold_gains_months, :month
    add_index :gold_gains_months, :year
    add_index :gold_gains_months, :user_id
  end
end
