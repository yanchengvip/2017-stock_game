class AddEndDayToCoinBag < ActiveRecord::Migration[5.0]
  def change
    add_column :coin_bags, :end_day, :integer,default: 0,comment: '过期天数'
  end
end
