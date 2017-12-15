class AddRequestIpToUsers < ActiveRecord::Migration[5.0]
  def change

    add_column :users,:request_ip,:string,comment: '记录用户最后登录的ip'
  end
end
