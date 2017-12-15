class AddQrcodeStatusForQrcodes < ActiveRecord::Migration[5.0]
  def change
    add_column :qrcodes, :qrcode_status, :integer, default: 1, comment: '二维码状态,-1:删除,1:正常'
  end
end
