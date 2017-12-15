class AddSortToLottery < ActiveRecord::Migration[5.0]
  def change
    add_column :lotteries,:sort,:integer,default: 0,comment: "顶置排行"
  end
end
