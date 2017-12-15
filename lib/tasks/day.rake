namespace :day do
  desc 'day_joy 每天0点执行'
  task :day_joy => :environment do |t, args|
    SaleDiamond.update_opening_price #更新开盘价格
  end

  desc 'day_joy 每天17:30点执行'
  task :day_joy_17_30 => :environment do |t, args|
    User.cal_gold_gains #更新当天收益
    GoldGainsHistory.generate_week_data # 更新周收益数据
    GoldGainsHistory.generate_month_data # 更新月收益数据
    GoldGainsHistory.refresh_redis_datas
    ActiveRecord::Base.clear_active_connections!
  end

  desc 'day_joy 每天23_00点执行 撤单'
  task :day_joy_23_00 => :environment do |t, args|
    BookingTrade.where(status: 0).where("created_at < ?", Date.tomorrow.to_time ).each do |booking_trade|
      begin
        booking_trade.cancle
      rescue Exception => e
        Rails.logger.info(e)
      end
    end
  end

  desc 'day_joy 每天23:50点执行'
  task :day_joy_23_50 => :environment do |t, args|
    User.user_wechat_subscribe_csv #每天关注统计 每天23_50执行执行

  end

  # desc 'day_joy 每天17:31点执行'
  # task :day_joy_17_31 => :environment do |t, args|
  #   PayTribute.pay_tribute_count #朋友圈进贡 每周六17:31执行执行
  #
  # end

end
