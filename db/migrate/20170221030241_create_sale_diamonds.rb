class CreateSaleDiamonds < ActiveRecord::Migration[5.0]
  def change
    create_table :sale_diamonds, comment: "钻石表" do |t|
      t.string :name, comment: "钻石名称"
      t.boolean :is_published, default: true, comment: "是否在售"
      t.decimal :min_size, precision: 5, scale: 4, default:0, comment: "最小尺寸"
      t.decimal :max_size, precision: 5, scale: 4, default:0, comment: "最大尺寸"
      t.string :exchange_name, default: "", comment: "交易所名称"
      t.string :exchange_code, default: "", comment: "交易所编码"
      t.string :color, default: "", comment: "颜色"
      t.string :clarity, default: "", comment: "净度"
      t.decimal :current_price, precision: 10, scale: 2, default: 0, comment: "当前价格"
      t.decimal :opening_price, precision: 10, scale: 2, default: 0, comment: "开盘价"

      t.timestamps
    end
    add_index :sale_diamonds, :name
    add_index :sale_diamonds, :exchange_code
  end
end
