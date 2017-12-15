class CreateUserLoginLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :user_login_logs,comment: '用户登录记录日志表' do |t|
      t.integer :user_id, comment: '用户ID'
      t.string :request_ip, comment: '登录ip'
      t.date :login_date,comment: '在线日期'
      t.timestamps
    end

    add_index :user_login_logs,:user_id
  end
end
