class AddTimestampsToErrorLogs < ActiveRecord::Migration[5.0]
  def change
    add_column(:error_logs, :created_at, :datetime)
    add_column(:error_logs, :updated_at, :datetime)
  end
end
