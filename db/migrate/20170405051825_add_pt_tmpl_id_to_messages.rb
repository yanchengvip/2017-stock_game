class AddPtTmplIdToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :pt_tmpl_id, :string, comment: "语音模版编号"
    add_column :messages, :msg_type, :string, comment: "消息类型1：语言验证码2：语音通知（文本语言）3：语音通知（语音id）"
    add_column :messages, :is_voice, :boolean, comment: "是否语音验证码", default: false
  end
end
