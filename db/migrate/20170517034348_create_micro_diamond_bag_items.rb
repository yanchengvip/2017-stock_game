class CreateMicroDiamondBagItems < ActiveRecord::Migration[5.0]
  def change
    create_table :micro_diamond_bag_items, comment: "微钻红包明细" do |t|
      t.integer :micro_diamond_bag_id, comment: "外键id", default: 0
      t.integer :user_id, comment: "用户id", default: 0
      t.decimal :amount, precision: 15, scale: 2, comment: "红包金额", default: 0
      t.string :request_ip, comment: "ip"

      t.timestamps
    end
  end
end
