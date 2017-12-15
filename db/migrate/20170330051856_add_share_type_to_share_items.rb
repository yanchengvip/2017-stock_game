class AddShareTypeToShareItems < ActiveRecord::Migration[5.0]
  def change
    add_column :share_items, :share_type, :string, comment: "分享类型"
  end
end
