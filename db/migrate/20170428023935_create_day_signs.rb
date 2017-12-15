class CreateDaySigns < ActiveRecord::Migration[5.0]
  def change
    create_table :day_signs do |t|
      t.string :day, comment: '签到日期'
      t.integer :user_id, comment: '签到用户'
      t.decimal :amount, comment: '签到赠送钻石币'

      t.timestamps
    end

    add_index :day_signs, [:day, :user_id], unique: true
  end
end
