class CreateQrcodeScanRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :qrcode_scan_records, comment: "微信二维码扫描关注记录表" do |t|
      t.string :openid, comment: "扫描的用户微信openid"
      t.integer :user_id, comment: "扫描的用户ID"
      t.integer :share_user_id, comment: "分享二维码的用户ID"
      t.string :scene_id, comment: "微信场景值ID"
      t.string :qrcode_record_id, comment: "微信二维码表ID"
      t.timestamps
    end
    add_index :qrcode_scan_records, :openid
    add_index :qrcode_scan_records, :scene_id
  end
end
