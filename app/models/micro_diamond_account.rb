class MicroDiamondAccount < ApplicationRecord
  belongs_to :table, polymorphic: true
  belongs_to :user
  before_create :update_user_micro_diamond_amount
  MICROTYPE = {
      "充值兑换" => 1,
      "微钻红包" => 2,
  }




  #我的微钻使用记录
  def self.my_micro_record params
    week = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    current_user = params[:current_user]
    micro_type_name = MicroDiamondAccount::MICROTYPE.invert.stringify_keys
    @micro_records = MicroDiamondAccount.where(user_id: current_user.id).order('created_at desc')
                         .paginate(:page => params[:page] ||= 1, :per_page => 10)
    return [] if @micro_records.empty?
    t = @micro_records.first.created_at.strftime('%Y-%m')
    orders_arr = []
    order_arr_tmp = []
    @micro_records.each do |dia|
      t2 = dia.created_at.strftime('%Y-%m')
      w = dia.created_at.strftime('%w').to_i
      if t == t2
        order_arr_tmp << {id: dia.id, user_id: dia.user_id, micro_type: micro_type_name["#{dia.micro_type}"],
                          amount: dia.amount.to_i, created_year: dia.created_at.strftime('%Y年%m月'), created_week: week[w],
                          created_day: dia.created_at.strftime('%m-%d %H:%M'),created_year2: dia.created_at.strftime('%Y-%m')}
      else
        t = t2
        orders_arr << order_arr_tmp
        order_arr_tmp = []
        order_arr_tmp << {id: dia.id, user_id: dia.user_id, micro_type: micro_type_name["#{dia.micro_type}"],
                          amount: dia.amount.to_i, created_year: dia.created_at.strftime('%Y年%m月'), created_week: week[w],
                          created_day: dia.created_at.strftime('%m-%d %H:%M'),created_year2: dia.created_at.strftime('%Y-%m')}
      end
    end
    orders_arr << order_arr_tmp
    return orders_arr
  end


  private

  def update_user_micro_diamond_amount
    user = self.user
    user.lock!
    user.micro_diamond_amount += self.amount
    user.save!
  end

end