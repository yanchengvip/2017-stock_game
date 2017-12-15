namespace :minute do
  desc 'minute_job'
  task :minute_job => :environment do |t, args|
    SaleDiamond.update_all_price
    # SaleDiamond.crawler_price
    # BookingTrade.check_price
  end

  desc "获取重庆时时彩数据/开奖"
  task :cqssc_minute_job => :environment do |t, args|
    begin
      Cqssc.update_data_from_apiplus
    rescue Exception => e
      p e
      Rails.logger.info(e)
    end
    begin
      Lottery.prize_draw
    rescue Exception => e
      p e
      Rails.logger.info(e)
    end
  end
end
