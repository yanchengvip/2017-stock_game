class CreateGoldGainsWeeks < ActiveRecord::Migration[5.0]
  def change
    create_table :gold_gains_weeks do |t|
      t.integer :user_id
      t.decimal :amount, precision: 10, scale: 2,default: 0

      t.timestamps
    end
  end
end
