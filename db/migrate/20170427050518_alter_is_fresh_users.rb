class AlterIsFreshUsers < ActiveRecord::Migration[5.0]
  def self.up
    change_table :users do |t|
      t.change :is_fresh, :boolean, default: true, comment: '是否宝箱新手'
    end
  end

  def self.down
    change_table :users do |t|
      t.change :is_fresh, :boolean
    end
  end
end
