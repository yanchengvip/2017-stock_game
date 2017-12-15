class TradeBox < ApplicationRecord
  validates :user_id, uniqueness: { scope: :day,
    message: "一天只能开启一次" }
  after_create :gold_account_add
  private
  def gold_account_add
    if SYSTEMCONFIG["admin_config"]["box"]["gold"].to_i > 0
      GoldAccount.create(user_id: self.user_id, amount: self.amount, account_type: GoldAccount::ACCOUNTTYPE["交易宝箱"], table_type: "TradeBox", table_id: self.id, available_gold_amount: self.amount)
    elsif SYSTEMCONFIG["admin_config"]["box"]["diamond_account"].to_i > 0
      DiamondAccount.create(user_id: self.user_id, amount: SYSTEMCONFIG["admin_config"]["box"]["diamond_account"], diamond_type: DiamondAccount::DIAMONDTYPE["交易宝箱"], table_type: "TradeBox", table_id: self.id)
    end
  end
end
