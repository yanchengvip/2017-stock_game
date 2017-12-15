#统计类型statistic_type;1:用户基本情况统计,2:资金金额统计,3:资金变动统计，4:资金月报统计,5:每天关注统计,6:中奖订单统计
class CsvFile < ApplicationRecord
  belongs_to :user


end