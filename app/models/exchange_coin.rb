# 兑换钻石币记录
class ExchangeCoin < ApplicationRecord
  belongs_to :user
  belongs_to :gold_account
  belongs_to :diamond_account


  after_create :generate_gold_diamond_account

  private
  def generate_gold_diamond_account
    gold_account = GoldAccount.create!(user_id: self.user_id, amount: -self.gold_amount, available_gold_amount: -self.gold_amount, 
                                                                account_type: GoldAccount::ACCOUNTTYPE['虚拟金兑换'], table_type: "ExchangeCoin", table_id: self.id)
    diamond_account = DiamondAccount.create!(user_id: self.user_id, amount: self.num, diamond_type: DiamondAccount::DIAMONDTYPE['虚拟金兑换'])
    res = gold_account && diamond_account

    self.update(gold_account_id: gold_account.id, diamond_account_id: diamond_account.id) if res
  end
end
