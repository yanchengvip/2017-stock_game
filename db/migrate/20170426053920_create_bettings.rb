class CreateBettings < ActiveRecord::Migration[5.0]
  def change
    create_table :bettings do |t|
      t.integer :user_id, comment: '用户'
      t.integer :amount, comment: '钻石币数量'
      t.decimal :odds, precision: 3, scale: 2, null: false, default: 0.00, comment: '赔付'
      t.integer :bet_type, comment: '投注类型 0：首次投注，1：普通投注，2:分享赠送'
      t.integer :chest_id, comment: '宝箱id'
      t.string :request_ip, comment: 'ip地址'

      t.timestamps
    end

    add_index :bettings, :user_id
    add_index :bettings, :chest_id
  end
end
