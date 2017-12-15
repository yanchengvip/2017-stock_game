class AddMicroDiamondToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :micro_diamond_amount, :integer, default: 0, comment: '微钻数量'
  end
end
