class CreateLotteries < ActiveRecord::Migration[5.0]
  def change
    create_table :lotteries, comment: "抽奖表" do |t|
      t.integer :product_id, comment: "商品id"
      t.datetime :published_at, comment: "发布时间"
      t.string :product_name, comment: "商品名称"
      t.integer :sales_count,default: 0, comment: "已售数量"
      t.integer :total_count,default: 0, comment: "总数"
      t.decimal :price, precision: 10, scale: 2,default: 0, comment: "单价"
      t.integer :status,default: 0, comment: "0 初始 -1 取消 1 待开奖 2 已开奖"
      t.datetime :lottery_time, comment: "开奖时间"
      t.string :share_code, comment: "分享编码"

      t.timestamps
    end
  end
end
