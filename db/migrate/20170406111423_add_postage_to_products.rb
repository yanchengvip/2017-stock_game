class AddPostageToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :postage, :integer,default: 0, comment: "邮费"
  end
end
