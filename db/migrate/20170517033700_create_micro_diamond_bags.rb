class CreateMicroDiamondBags < ActiveRecord::Migration[5.0]
  def change
    create_table :micro_diamond_bags, comment: "红包" do |t|
      t.decimal :micro_diamond_amount, precision: 15, scale: 2, comment: "微钻红包金额", default: 0
      t.integer :person_count, comment: "红包人数", default: 0
      t.decimal :buy_diamond_amount, precision: 10, scale: 2, comment: "微钻红包 购买钻币数", default: 0
      t.datetime :published_at, comment: "上架时间"
      t.datetime :buy_at, comment: "开抢时间"
      t.integer :status, comment: "状态 0 未开始 1 进行中 2 已结束", default: 0
      t.boolean :is_active, comment: "是否启用", default: true
      t.integer :duration_time, comment: "持续秒数", default: 0

      t.timestamps
    end
  end
end
