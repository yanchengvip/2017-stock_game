class CreateErrorLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :error_logs do |t|
      t.string :title, comment: '错误标题'
      t.integer :status, default: 0, comment: '日志类型'
      t.text :desc, comment: '错误描述'

    end
  end
end
