class CoinBagLotteryItem < ApplicationRecord
  belongs_to :user
  belongs_to :coin_bag
  belongs_to :coin_bag_lottery
  validates :user_id, uniqueness: { scope: :coin_bag_lottery_id,
    message: "should happen once per coin_bag_lottery_id" }

  after_create :create_diamond_account
  private
  def create_diamond_account
    DiamondAccount.create( user_id: self.user_id, amount: self.coin_count, diamond_type: DiamondAccount::DIAMONDTYPE["钻币礼包"])
  end
end
