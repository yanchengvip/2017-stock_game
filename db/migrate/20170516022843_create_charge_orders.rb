class CreateChargeOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :charge_orders, comment: "充值现金表" do |t|
      t.integer :user_id
      t.integer :pay_type, default: 0, comment: ' 0: 无,1:支付宝支付,2:微信支付,3:mustpay平台的微信服务号支付'
      t.integer :status, default: 0, comment: '-1:订单删除，0:未支付,1:支付成功,2:支付失败,3:未付款交易超时关闭'
      t.decimal :price, precision: 10, scale: 2, default: 0, comment: '充值金额'
      t.integer :micro_diamond, default: 0, comment: '微钻数量'
      t.string  :code,comment: '订单编号'
      t.timestamps
    end
  end
end
