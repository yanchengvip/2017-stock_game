class CreateGoldGainsHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :gold_gains_histories do |t|
      t.integer :user_id
      t.decimal :amount, precision: 10, scale: 2,default: 0
      t.string :day

      t.timestamps
    end
  end
end
