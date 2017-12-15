class AddDayToExchangeCoins < ActiveRecord::Migration[5.0]
  def change
    add_column :exchange_coins, :day, :string, comment: '兑换日期天'

    add_index :exchange_coins, :day
  end
end
