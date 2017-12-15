class AddAutoPublisedToLotteries < ActiveRecord::Migration[5.0]
  def change
    add_column :lotteries, :auto_extension_status, :integer, default: 1, comment: '是否自动延续下一期1:不自动延续,2:自动延续,3:已经完成自动延续'
    add_column :lotteries, :auto_extension_start_time, :integer,default: 0, comment: '自动延续开始时间'
    add_column :lotteries, :auto_extension_end_time, :integer,default: 0, comment: '自动延续结束时间'
    add_column :lotteries, :auto_extension_interval, :integer, default: 5, comment: '自动延续时间间隔/分钟'
  end
end
