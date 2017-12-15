class AddShareConfigIdToShareItem < ActiveRecord::Migration[5.0]
  def change
    add_column :share_items, :share_config_id, :string
  end
end
