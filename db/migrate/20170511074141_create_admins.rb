class CreateAdmins < ActiveRecord::Migration[5.0]
  def change
    create_table :admins do |t|
      t.string :nickname, comment: '管理员名称'
      t.string :phone, comment: '管理员手机号'
      t.string :encrypted_password, comment: '登录密码'
      t.string :role, default: 0, comment: '用户角色 0:无, 2:管理员'
      t.string :salt
      t.integer :status, default: 1, comment: '用户状态 -1:删除,0:禁用,1:正常'
      t.string :request_ip
      t.timestamps
    end
  end
end
