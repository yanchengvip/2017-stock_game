class CreateDiamondAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :diamond_accounts, comment: "钻石币账户明细" do |t|
      t.integer :user_id, default: 0, comment: "用户id"
      t.decimal :amount, precision: 10, scale: 2, default: 0, comment: "变化金额"
      t.integer :diamond_type, default: 0, comment: "类型"
      t.timestamps
    end
  end
end
