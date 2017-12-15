class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.string :psz_sub_port, default: "*", comment: "扩展子号"
      t.integer :i_mobi_count, default: 0, comment: "手机号码个数"
      t.text :psz_msg, comment: "短信内容，最大支持350个字"
      t.text :psz_mobis, comment: "手机号码，用英文逗号(,)分隔，最大1000个号码"
      t.string :request_ip, default: "", comment: "ip地址"
      t.string :channel_name, default: "梦网", comment: "通道名"
      t.string :response_code, default: "", comment: "返回编码"
      t.timestamps
    end
    add_index :messages, :request_ip
  end
end
