module Admins::DownloadCsvHelper

  def statistic_type_name type
     name = ''
     case type.to_i
       when 1
         name = '用户基本情况统计'
       when 2
         name = '资金余额统计'
       when 3
         name = '资金变动统计'
       when 4
         name = '资金月报统计'
       when 5
         name = '每天关注统计'
       when 6
         name = '中奖订单统计'
     end

    return name
  end
end