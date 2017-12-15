class CreateCouriers < ActiveRecord::Migration[5.0]
  def change
    create_table :couriers do |t|
      t.integer :table_id
      t.string :table_type
      t.string :courier_no,comment: '快递单号'
      t.string :courier_name,comment: '物流公司'

      t.timestamps
    end
  end
end
