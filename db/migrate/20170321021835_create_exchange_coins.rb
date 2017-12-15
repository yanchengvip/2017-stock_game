class CreateExchangeCoins < ActiveRecord::Migration[5.0]
  def change
    create_table :exchange_coins do |t|
      t.integer :user_id, comment: '兑换人'
      t.integer :diamond_exchange_rate, comment: '兑换时兑换汇率'
      t.integer :num, comment: '兑换数量'
      t.integer :gold_account_id, comment: '资金记录'
      t.integer :diamond_account_id, comment: '钻石记录'

      t.timestamps
    end

    add_index :exchange_coins, :user_id
    add_index :exchange_coins, :gold_account_id
    add_index :exchange_coins, :diamond_account_id
  end
end
