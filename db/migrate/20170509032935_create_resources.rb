class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources, comment: "权限资源表" do |t|
      t.string :name, comment: '资源名称'
      t.integer :status, default: 0, comment: '资源状态,0:禁用,1:启用'
      t.string :model_n, comment: 'Model名称'
      t.string :controller_n, comment: 'Controller名称'
      t.string :action_n, comment: 'Action名称'
      t.string :desc, comment: '备注'
      t.timestamps
    end
  end
end
