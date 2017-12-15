class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.integer :user_id, comment: "用户ID"
      t.string :user_name, comment: "真实姓名"
      t.string :phone, comment: "手机"
      t.string :postcode, comment: "用户所在邮编号"
      t.string :address, comment: "接收快递详细地址"
      t.boolean :is_default,default: false,comment: "是否为默认地址"
      t.timestamps
    end
  end
end
