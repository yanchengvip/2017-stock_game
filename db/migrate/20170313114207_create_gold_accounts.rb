class CreateGoldAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :gold_accounts, comment: '用户虚拟金明细表' do |t|
      t.integer :user_id, default:0, comment: "用户id"
      t.decimal :amount, precision: 10, scale: 2, default: 0,  comment: "数额"
      t.integer :account_type, default: 0,  comment: "类型"
      t.string :table_type, default: "",  comment: "关联表"
      t.integer :table_id, default: 0,  comment: "关联表id"

      t.timestamps
    end
  end
end
