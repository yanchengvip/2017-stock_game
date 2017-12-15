class PayRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :pay_records do |t|
      t.integer :user_id, comment: '用户ID'
      t.integer :pay_type, default: 0, comment: '0: 无,1:支付宝支付,2:微信支付'
      t.integer :table_id, comment: "table_id"
      t.string :table_type, comment: "table_type"
      t.datetime :notify_time, comment: "支付成功通知时间"
      t.string :trade_no, comment: "交易凭证号"
      t.string :out_trade_no, comment: "原支付请求的商户订单号"
      t.string :buyer_id, comment: "买家支付宝/微信用户号"
      t.string :buyer_logon_id, comment: "买家支付宝/微信账号"
      t.string :seller_id, comment: "卖家支付宝/微信用户号	"
      t.string :seller_email, comment: "卖家支付宝/微信账号"
      t.string :trade_status, comment: "交易状态"
      t.decimal :total_amount, precision: 10, scale: 2, default: 0, comment: "订单金额"
      t.decimal :receipt_amount, precision: 10, scale: 2, default: 0, comment: "商家在交易中实际收到的款项"
      t.decimal :buyer_pay_amount, precision: 10, scale: 2, default: 0, comment: "用户在交易中支付的金额"

      t.timestamps
    end

    add_index :pay_records, :user_id
    add_index :pay_records, :table_id
    add_index :pay_records, :table_type
    add_index :pay_records, :buyer_logon_id
  end
end
