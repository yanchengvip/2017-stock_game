#product_type 0:无类型,1:夺宝产品,2:福袋产品
#product_second_type 商品的二级类型; 0:无,1:赠送钻币的夺宝商品
class Product < ApplicationRecord
  has_many :images, as: :table, dependent: :destroy
  has_many :lotteries, dependent: :destroy
  has_many :lottery_orders, through: 'lotteries'
  has_many :ranking_config_items, as: :table
  belongs_to :product_tag
  validates :inventory_count, numericality: {greater_than_or_equal_to: 0}
  validates :lottery_percent, numericality: {greater_than: 0, less_than_or_equal_to: 1}
  scope :Indianas, -> { where(product_type: 1) } #1夺宝产品
  scope :bags, -> { where(product_type: 2) } #2:福袋产品
  include Admins::SearchHelper

  #1夺宝产品
  def is_Indiana?
    product_type == 1
  end

  # 2:福袋产品
  def is_bag?
    product_type == 2
  end


end
