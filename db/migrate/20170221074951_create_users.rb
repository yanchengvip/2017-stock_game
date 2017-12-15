class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users, comment: "用户表" do |t|
      t.string :phone, comment: "手机号"
      t.string :encrypted_password, comment: "密码"

      t.string :province, comment: "省份"
      t.string :openid, comment: "openid"
      t.string :nickname, comment: "微信昵称"
      t.integer :sex, comment: "性别"
      t.string :city, comment: "市"
      t.string :country, comment: "国家"
      t.string :headimgurl, comment: "头像地址"
      t.string :unionid, comment: "unionid"

      t.timestamps
    end
    add_index :users, :phone
    add_index :users, :openid
  end
end
