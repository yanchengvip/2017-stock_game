class AddGoldAmountToExchangeCoins < ActiveRecord::Migration[5.0]
  def change
    add_column :exchange_coins, :gold_amount, :integer, comment: '花费的虚拟资金'
  end
end
