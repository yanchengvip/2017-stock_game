class DiamondAccount < ApplicationRecord
  belongs_to :user
  belongs_to :table, polymorphic: true
  belongs_to :follower_user, class_name: "User", foreign_key: "table_id"
  before_create :update_user_total_diamond_coin

  DIAMONDTYPE = {
    "夺宝" => 1,
    "夺宝退款" => -1,
    "虚拟金兑换" => 2,
    "钻币礼包" => 10,
    "0元夺宝奖品兑换" => 20,
    "系统赠送" => 100,
    "日排行奖励" => 101,
    "周排行奖励" => 102,
    "月排行奖励" => 103,
    "总排行奖励" => 104,
    "注册赠送" => 30,
    "邀请注册赠送" => 31,
    "福袋中奖分享" => 32,
    "夺宝中奖分享" => 33,
    "交易宝箱" => 34,
    "进贡" => 35,
    "吃贡" => 36,
    "排名获奖分享" => 37,
    "关注钻石大富翁公众号奖励" => 38,
    "宝箱投注扣除本金" => 39,
    "宝箱投注获得奖励" => 40,
    "宝箱每日免费赠送" => 41,
    "宝箱分享赠送" => 42,
    "每日签到赠送" => 43,
    "每日分享赠送钻币" => 44,
    "0元夺宝中奖赠送" => 45,
    "微钻红包" => 50,
  }

  self.xml_options = {
    :only => ["id", "user_id", "amount", "diamond_type", "created_at", "updated_at", "table_type", "table_id"].freeze,
    :include => {
      :follower_user => { :only => ["id", "headimgurl", "nickname", "phone"] },
    }
  }


  #我的钻币记录
  def self.my_diamond_account_record params
    week = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    current_user = params[:current_user]
    dianmond_type_name = DiamondAccount::DIAMONDTYPE.invert.stringify_keys
    @diamond_accounts = DiamondAccount.where(user_id: current_user.id).order('created_at desc').paginate(:page => params[:page] ||= 1, :per_page => 10)
    return [] if @diamond_accounts.empty?
    t = @diamond_accounts.first.created_at.strftime('%Y-%m')
    orders_arr = []
    order_arr_tmp = []
    @diamond_accounts.each do |dia|
      t2 = dia.created_at.strftime('%Y-%m')
      w = dia.created_at.strftime('%w').to_i
      if t == t2
        order_arr_tmp << {id: dia.id, user_id: dia.user_id, diamond_type: dianmond_type_name["#{dia.diamond_type}"],
                          amount: dia.amount.to_i, created_year: dia.created_at.strftime('%Y年%m月'), created_week: week[w],
                          created_day: dia.created_at.strftime('%m-%d %H:%M'),created_year2: dia.created_at.strftime('%Y-%m')}
      else
        t = t2
        orders_arr << order_arr_tmp
        order_arr_tmp = []
        order_arr_tmp << {id: dia.id, user_id: dia.user_id, diamond_type: dianmond_type_name["#{dia.diamond_type}"],
                          amount: dia.amount.to_i, created_year: dia.created_at.strftime('%Y年%m月'), created_week: week[w],
                          created_day: dia.created_at.strftime('%m-%d %H:%M'),created_year2: dia.created_at.strftime('%Y-%m')}
      end
    end
    orders_arr << order_arr_tmp
    return orders_arr
  end


  private
  def update_user_total_diamond_coin
    user = self.user
    user.with_lock do
      user.total_diamond_coin +=  self.amount
      user.save!
    end
  end
end
