class CreatePayTributes < ActiveRecord::Migration[5.0]
  def change
    create_table :pay_tributes do |t|
      t.integer :user_id, comment: "吃贡用户的ID"
      t.integer :tribute_user_id, comment: "进贡用户的ID"
      t.decimal :amount, precision: 10, scale: 2, default: 0,  comment: "数额;吃贡正数，进贡负数"
      t.integer :share_user_id,default: 0,comment: "群主ID"
      t.integer :tribute_type,default: 0,comment: '1：吃贡,2:进贡'
      t.integer :week,comment: "周"
      t.integer :year,comment: "年"
      t.timestamps
    end
  end
end
