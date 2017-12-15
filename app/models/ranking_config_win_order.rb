# 奖励领取实际订单项表
#status  订单状态 -1:已作废 0:未发货,1:已发货,2:已兑换收益,3:待发货
class RankingConfigWinOrder < ApplicationRecord
  belongs_to :ranking_config_item
  belongs_to :ranking_config_win
  belongs_to :user
  belongs_to :product
  has_one :ranking_config,through: :ranking_config_win
  delegate :ranking_config,:to => :ranking_config_win
  has_many :couriers,as: :table
  belongs_to :address
  has_many :pay_records,as: :table
  include Admins::SearchHelper
  after_create :generate_win_order_code


  private

  def generate_win_order_code
    code = Utils.generate_r_code self.id
    order.update_attributes(code: code)
  end

end
