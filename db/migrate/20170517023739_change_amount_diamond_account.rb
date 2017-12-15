class ChangeAmountDiamondAccount < ActiveRecord::Migration[5.0]
  def change
    change_column :micro_diamond_accounts, :amount, :decimal,precision: 20,scale: 2, default: 0, comment: '变化金额'
    change_column :users, :micro_diamond_amount, :decimal,precision: 20,scale: 2, default: 0, comment: '微钻数量'
    change_column :charge_orders, :micro_diamond_amount, :decimal,precision: 20,scale: 2, default: 0, comment: '微钻数量'
  end
end
