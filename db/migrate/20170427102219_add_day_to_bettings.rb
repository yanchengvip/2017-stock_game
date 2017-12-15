class AddDayToBettings < ActiveRecord::Migration[5.0]
  def change
    add_column :bettings, :day, :string, comment: '天'

    add_index :bettings, :day
  end
end
