class AddStatusToAddress < ActiveRecord::Migration[5.0]
  def change
    add_column :addresses, :status, :integer, default: 0, comment: '-1:删除,0:正常'
  end
end
