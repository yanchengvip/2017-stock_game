#记录用户在线的天数，同一天多次登录在线，仅保存一条记录
class UserLoginLog < ApplicationRecord
  belongs_to :user
  validates_uniqueness_of :user_id, :scope => :login_date
end