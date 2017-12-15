class ChangeQrcodeRecordIdToQrcodeIdForScanRecord < ActiveRecord::Migration[5.0]
  def change
    rename_column :qrcode_scan_records, :qrcode_record_id, :qrcode_id

  end
end
