class LotteryOrderItem < ApplicationRecord
  belongs_to :lottery_order
  belongs_to :lottery
  belongs_to :user
  has_one :product,through: :lottery
  delegate :products, :to => :product
  include Admins::SearchHelper
  validates :lottery_code, uniqueness: { scope: :lottery_id,
    message: "should happen once per lottery_id" }

  BEGINNUMBER = 10000001
end
