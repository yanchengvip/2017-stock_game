class UserSignLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :user_sign_logs, comment: '用户微信注册或者取消关注记录' do |t|
      t.integer :user_id, comment: '用户ID'
      t.string :phone, comment: '用户手机号'
      t.string :openid, comment: '用户微信openid'
      t.integer :user_status, default: 0, comment: '用户状态;0:无,1:微信关注,2:取消关注,3:h5注册'
      t.string :request_ip, comment: '用户ip'
      t.date :record_date, comment: '记录日期'
      t.timestamps
    end

    add_index :user_sign_logs, [:openid, :user_status, :record_date]
  end
end
