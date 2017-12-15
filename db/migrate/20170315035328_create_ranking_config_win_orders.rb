class CreateRankingConfigWinOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :ranking_config_win_orders do |t|
      t.integer :ranking_config_item_id
      t.integer :ranking_config_win_id
      t.integer :user_id
      t.integer :status,default:0, comment: "订单状态 -1:已作废 0:未发货,1:已发货,2:已兑换收益"
      t.integer :product_id,comment: "产品ID"
      t.integer :total_count,default: 0, comment: "购买总数"
      t.decimal :total_price, precision: 10, scale: 2,default: 0, comment: "总价"
      t.integer :address_id, comment: "收货地址id"
      t.string :request_ip, comment: "用户ip"

      t.timestamps
    end
  end
end
