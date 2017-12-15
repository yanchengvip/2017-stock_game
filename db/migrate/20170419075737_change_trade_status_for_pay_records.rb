class ChangeTradeStatusForPayRecords < ActiveRecord::Migration[5.0]
  def change
    remove_column :pay_records, :trade_status
    add_column :pay_records, :trade_status, :integer,default: 0, comment: '交易状态;1:交易创建,2:交易关闭,3:支付成功,4:交易完成'
  end
end
