class CoinBag < ApplicationRecord
  has_many :coin_bag_lotteries,dependent: :destroy
  has_many :coin_bag_lottery_items,dependent: :destroy

  include Admins::SearchHelper
end
