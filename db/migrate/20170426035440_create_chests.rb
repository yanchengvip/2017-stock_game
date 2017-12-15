class CreateChests < ActiveRecord::Migration[5.0]
  def change
    create_table :chests do |t|
      t.decimal :odds, precision: 3, scale: 2, null: false, default: 0.00, comment: '赔付'
      t.integer :total_count, default: 0, comment: '数量'
      t.integer :status, default: 1, comment: '状态，0:停用，1:启用'

      t.timestamps
    end
  end
end
