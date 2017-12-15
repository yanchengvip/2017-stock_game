# 0:无，1：普通用户，2：管理员，3：内测用户
class Role < ApplicationRecord
  belongs_to :user
end