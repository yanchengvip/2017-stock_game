class AddCnNameToSaleDiamonds < ActiveRecord::Migration[5.0]
  def change
    add_column :sale_diamonds, :cn_name, :string, comment: "钻石名称"
  end
end
