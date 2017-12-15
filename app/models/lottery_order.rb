#status 订单状态 -1:已作废 0:未发货(未付款),1:已发货,2:已兑换收益,3:待发货(已付款)4:待付运费(待付运费)
class LotteryOrder < ApplicationRecord
  belongs_to :lottery
  belongs_to :user
  has_many :lottery_order_items, dependent: :destroy
  has_one :product, through: :lottery
  has_many :couriers, as: :table
  delegate :products, :to => :product
  belongs_to :address
  has_many :pay_records, as: :table
  validates :user_id, uniqueness: {scope: :lottery_id,
                                   message: "福袋只能开启一次"}, if: :is_luck_package?

  after_create :generate_code
  include Admins::SearchHelper
  self.xml_options = {
      :only => ["id", "lottery_id", "user_id", "request_ip", "total_count", "total_price", "is_win", "status", "address_id", "created_at", "updated_at"].freeze,
      :include => {
        :user => {:only => ["id", "phone", "nickname", "headimgurl"]},
        :product => { :only => ["id", "name"] },
        :lottery_order_items => {only: [:lottery_code, :is_win]}
      }
  }

  def is_luck_package?
    $cache.fetch("lottery_#{self.lottery_id}_is_luck_package", 60) {
      self.lottery.product_type == 2
    }
  end

  def take_award(params, courrent_user)
    res = {}
    self.with_lock do
      if self.is_win == true && self.status == 0 && courrent_user.id == self.user_id
        if params[:type].to_i == 1 #直接领奖
          if self.lottery.product_type.to_i == 1 && self.product.postage.to_f != 0
            #夺宝产品,支付邮费
            ActiveRecord::Base.transaction do
              if self.address.present?
                self.address.update_attributes!(params[:address].as_json.merge(user_id: self.user_id))
              else
                address = Address.create!(params[:address].as_json.merge(user_id: self.user_id))
                self.update_attributes!(address_id: address.id)
              end
            end
            return {status: 600, msg: "跳转支付宝页面", data: {}}
          end
          begin
            ActiveRecord::Base.transaction do
              address = Address.create!(params[:address].as_json.merge(user_id: self.user_id))
              self.update_attributes!(address_id: params[:address], status: 3)
              self.lottery.update_attributes!(take_award: true)
            end
            res = {status: 200, msg: "领奖成功", data: {}}
          rescue Exception => e
            Rails.logger.info(e)
            res = {status: 500, msg: "提交服务器失败，稍后重试", data: {}}
          end
        elsif params[:type].to_i == 2 && self.lottery.take_award == false #兑换钻石币
          self.update_attributes!(status: 2)
          diamond_account = DiamondAccount.create(user_id: self.user_id, amount: ((self.lottery.total_count * self.lottery.price) * (1 - SYSTEMCONFIG[:lottery_system_persent].to_f)).to_i, diamond_type: DiamondAccount::DIAMONDTYPE["0元夺宝奖品兑换"])
          self.lottery.update_attributes!(take_award: true)
          product = self.lottery.product
          product.with_lock do
            product.update_attributes!(inventory_count: product.inventory_count + 1 )
          end
          res = {status: 200, msg: "兑换钻石币", data: diamond_account.amount}
        else
          res = {status: 500, msg: "提交服务器失败，稍后重试", data: {}}
        end
      else
        res = {status: 500, msg: "领取成功", data: {}}
      end
    end
    res
  end


  after_create :create_lottery_order_items
  private
  def create_lottery_order_items
    if self.lottery.product_type == 2
      if self.total_count < 10
        LotteryOrderJob.perform_now(self.id)
      else
        LotteryOrderJob.delay_for(1.seconds).perform_now(self.id)
      end
    else
      if self.total_count < 10
        LotteryOrderIndianaJob.perform_now(self.id)
      else
        LotteryOrderIndianaJob.delay_for(1.seconds).perform_now(self.id)
      end
    end

    # user = self.user
    # if user.share_user_id && !user.share_user_gived && self.total_count >= 1 && (share_user = User.where(id: user.share_user_id).first)
    #   User.transaction do
    #     invite_count = User.where(share_user_id: user.share_user_id, share_user_gived: true).lock.count
    #     unless invite_count >= SYSTEMCONFIG[:admin_config][:invite_user_each][:limit_count]
    #       if SYSTEMCONFIG[:admin_config][:invite_user_each][:diamond_account] && SYSTEMCONFIG[:admin_config][:invite_user_each][:diamond_account] > 0
    #         DiamondAccount.create!(user_id: user.share_user_id, amount: SYSTEMCONFIG[:admin_config][:invite_user_each][:diamond_account], diamond_type: DiamondAccount::DIAMONDTYPE["邀请注册赠送"], table_type: "User", table_id: self.user_id)
    #         user.update_attributes!(share_user_gived: true)
    #       end
    #     end
    #   end
    # end

    # self.total_count.times{ self.lottery_order_items.create(lottery_id: self.lottery_id, user_id: self.user_id, request_ip: self.request_ip) }
    # self.lottery.update_attributes!(sales_count: LotteryOrder.where(lottery_id: self.lottery_id).sum(:total_count))
  end


  #生成订单号
  def generate_code
      code = Utils.generate_l_code self.id
      self.update_attributes({code: code})
  end
end
