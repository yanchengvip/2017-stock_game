class CreateCqsscs < ActiveRecord::Migration[5.0]
  def change
    create_table :cqsscs, comment: "重庆时时彩" do |t|
      t.string :expect, comment: "期号"
      t.string :opencode, comment: "开奖号码"
      t.string :opentime, comment: "开奖时间"
      t.string :opentimestamp, comment: "开奖戳"

      t.timestamps
    end
  end
end
