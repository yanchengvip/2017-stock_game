class AddIsShareToBettings < ActiveRecord::Migration[5.0]
  def change
    add_column :bettings, :is_share, :boolean, default: false, comment: '是否已分享'
  end
end
