class AddShareTypeToShareConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :share_configs, :share_type, :string, default: 0, comment: '0:初始,1:微信内容分享,2:公告管理'
    add_column :share_configs, :status, :integer, default: 0, comment: '0:禁用，1:启用'
  end
end
