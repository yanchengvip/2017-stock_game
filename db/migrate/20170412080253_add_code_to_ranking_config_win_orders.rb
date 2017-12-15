class AddCodeToRankingConfigWinOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :ranking_config_win_orders, :code, :string, comment: '订单编号'
  end
end
