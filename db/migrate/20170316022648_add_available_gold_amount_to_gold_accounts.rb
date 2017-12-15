class AddAvailableGoldAmountToGoldAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :gold_accounts, :available_gold_amount, :decimal, precision: 10, scale: 2, default:0, comment: "虚拟金可用资金变化"
  end
end
