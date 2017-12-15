class ChangeBusinessTypeToDiamondTrades < ActiveRecord::Migration[5.0]
  def change
    rename_column :diamond_trades, :business_type, :bussiness_type
  end
end
