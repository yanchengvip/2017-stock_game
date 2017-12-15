class ChangeDatetimeLimitForMysql < ActiveRecord::Migration[5.0]
  def change
    change_column :lottery_order_items, :created_at, :datetime, limit: 6
    change_column :lottery_order_items, :updated_at, :datetime, limit: 6
  end
end
