class GoldAccount < ApplicationRecord
  before_create :update_user_total_gold
  belongs_to :user
  belongs_to :table, polymorphic: true
  belongs_to :follower_user, class_name: "User", foreign_key: "table_id"

  ACCOUNTTYPE = {
    "系统赠送" => 100,
    "注册系统赠送" => 99,
    "无分配" => 0,
    "日排行奖励" => 101,
    "周排行奖励" => 102,
    "月排行奖励" => 103,
    "总排行奖励" => 104,
    "买入" => 1,
    "卖出" => 2,
    "做空" => 3,
    "平仓" => 4,
    "买入挂单" => 11,
    "卖出挂单" => 12,
    "做空挂单" => 13,
    "平仓挂单" => 14,

    "买入撤单" => -11,
    "卖出撤单" => -12,
    "做空撤单" => -13,
    "平仓撤单" => -14,

    "邀请注册" => 21,
    "虚拟金兑换" => 22,
    "交易宝箱" => 50,
  }
  private
  def update_user_total_gold
    user = self.user
    user.with_lock do
      user.total_gold +=  self.amount
      user.available_gold += self.available_gold_amount
      user.save!
    end
  end
end
