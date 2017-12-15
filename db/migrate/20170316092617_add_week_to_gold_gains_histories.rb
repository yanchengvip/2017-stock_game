class AddWeekToGoldGainsHistories < ActiveRecord::Migration[5.0]
  def change
    add_column :gold_gains_weeks, :week, :integer, comment: '第几周'
    add_column :gold_gains_weeks, :year, :integer, comment: '年份'

    add_index :gold_gains_weeks, :week
    add_index :gold_gains_weeks, :year
    add_index :gold_gains_weeks, :user_id
  end
end
