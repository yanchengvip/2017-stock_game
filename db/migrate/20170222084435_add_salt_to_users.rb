class AddSaltToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :salt, :string, comment: "salt"
  end
end
