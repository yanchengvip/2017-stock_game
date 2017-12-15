namespace :rank do
  desc '生成周收益数据，每周六17:30开奖'
  task :rank_week => :environment do |t, args|
    GoldGainsHistory.generate_week_data
    ActiveRecord::Base.clear_active_connections!
  end

  desc '生成月收益数据，每月月末开奖'
  task :rank_month => :environment do |t, args|
    GoldGainsHistory.generate_month_data
    ActiveRecord::Base.clear_active_connections!
  end
end