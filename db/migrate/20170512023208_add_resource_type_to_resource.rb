class AddResourceTypeToResource < ActiveRecord::Migration[5.0]
  def change
    add_column :resources,:resource_type,:integer,default: 0,comment: '0:无，1：前端H5权限资源，2：后台权限资源'
  end
end
