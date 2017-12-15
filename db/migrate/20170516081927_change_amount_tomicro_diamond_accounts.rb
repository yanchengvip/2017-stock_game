class ChangeAmountTomicroDiamondAccounts < ActiveRecord::Migration[5.0]
  def change
    change_column :micro_diamond_accounts, :amount, :decimal,precision: 10,scale: 2, default: 0, comment: '变化金额'
    change_column :users, :micro_diamond_amount, :decimal,precision: 10,scale: 2, default: 0, comment: '微钻数量'
    rename_column :charge_orders, :micro_diamond, :micro_diamond_amount
    change_column :charge_orders, :micro_diamond_amount, :decimal,precision: 10,scale: 2, default: 0, comment: '微钻数量'
  end
end
