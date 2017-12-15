class CreateMicroDiamondAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :micro_diamond_accounts do |t|
      t.integer :user_id, comment: '用户ID'
      t.integer :micro_type, default: 0, comment: '类型'
      t.integer :amount, default: 0, comment: '变化金额'
      t.string :table_type
      t.integer :table_id
    end
  end
end
