class CreateQrcodes < ActiveRecord::Migration[5.0]
  def change
    create_table :qrcodes, comment: "微信二维码表" do |t|
      t.integer :user_id, comment: "所属用户ID"
      t.string :qrcode_url, comment: "二维码图片地址"
      t.string :ticket, comment: "二维码ticket,用于换取二维码"
      t.string :scene_id, comment: "场景值ID"
      t.integer :qrcode_type, default: 0, comment: "二维码类型,0:无,1:临时二维码，2:永久二维码 "
      t.timestamps
    end
    add_index :qrcodes, :user_id
    add_index :qrcodes, :scene_id
  end
end
