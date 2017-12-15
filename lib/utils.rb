module Utils

  BEGINNUMBER = 10000001

  def self.generate_uuid
    UUIDTools::UUID.timestamp_create().to_s
  end


  def self.generate_random *args
    if args.present?
      Time.new.strftime("%Y%m%d%H%M%S") + args[0].to_i.to_s

    else
      Time.new.strftime("%Y%m%d%H%M%S")
    end

  end


  #订单号
  def self.generate_code *args
    args[0].to_s.upcase + Time.new.strftime("%Y%m%d%H%M%S") + args[1].to_i.to_s
  end
  #生成竞赛排行订单号
  def self.generate_r_code *args
    'R' + Time.new.strftime("%Y%m%d%H%M%S") + args[0].to_i.to_s
  end

  #生成夺宝或者福袋的订单号 lotterorder code
  def self.generate_l_code *args
    'L' + Time.new.strftime("%Y%m%d%H%M%S") + args[0].to_i.to_s
  end




  def self.time_format date_time
    if date_time.present?
      date_time = date_time.strftime('%Y-%m-%d %H:%M')
    else
      date_time = ''
    end
    return date_time
  end





end
