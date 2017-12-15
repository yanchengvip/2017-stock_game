class AddUserNameToQrcode < ActiveRecord::Migration[5.0]
  def change
    add_column :qrcodes, :user_name, :string, comment: "二维码拥有者名字"
  end
end
