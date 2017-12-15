#pay_type: 0: 无,1:支付宝支付,2:微信支付,3:mustpay平台的微信服务号支付
#status: -1:订单删除，0:未支付,1:支付成功,2:支付失败,3:未付款交易超时关闭
class ChargeOrder < ApplicationRecord
  validates :code, uniqueness: true
  validates :user_id, presence: true
  #validates :price, numericality: {greater_than_or_equal_to: 1}
  validates :price, numericality: {greater_than: 0}
  belongs_to :user
  has_many :pay_records, as: :table
  has_many :micro_diamond_accounts, as: :table
  after_create :generate_code
  after_create :generate_micro_diamond_amount

  #充值成功后回调处理
  def self.pay_notify_handle params
    flag = 'error'

    charge_order = ChargeOrder.includes(:user).where(code: params[:out_trade_no]).first
    if charge_order && charge_order.status.to_i == 0 && params[:total_amount].to_f == charge_order.price
      begin
        ActiveRecord::Base.transaction do
          if params[:trade_status] == 'TRADE_SUCCESS'
            charge_order.update_attributes!(status: 1, pay_type: params[:pay_types].to_i)
            charge_order.micro_diamond_accounts.create!(user_id: charge_order.user_id, micro_type: MicroDiamondAccount::MICROTYPE['充值兑换'],
                                                        amount: charge_order.micro_diamond_amount)
          elsif params[:trade_status] == 'TRADE_CLOSED'
            charge_order.update_attributes!(status: 3)
          end

          if params[:pay_types].to_i == 1
            #支付宝支付
            PayRecord.create_alipay_record(charge_order, params)
          elsif params[:pay_types].to_i == 3
            #mustpay平台的微信服务号支付
            PayRecord.create_mustpay_record(charge_order, params)
          end
           current_user = charge_order.user
           if current_user.status.to_i == 0
             current_user.update_attributes!(status: 1)
           end
          flag = 'success'
        end
      rescue Exception => e
        ErrorLog.create(status: 1, title: "充值成功后回调处理保存失败ChargeOrderID=#{charge_order.id}", desc: 'pay_notify_handle方法----' + e.to_s)
      end
    else
      ErrorLog.create(status: 1, title: "充值成功后回调处理保存失败out_trade_no=#{params[:out_trade_no]}", desc: 'pay_notify_handle方法，条件不满足')
    end
    return flag
  end


  def self.pay_charge_order params
    @charge_order = ChargeOrder.where(id: params[:id]).first
    if !@charge_order
      return false
    end

    case params[:pay_type].to_i
      when 1
        #支付宝支付方式
        p1 ={
            return_url: 'h5/users/home',
            notify_url: 'h5/alipay/notify',
            biz_content: {"subject": "充值订单", "out_trade_no": @charge_order.code,
                          "total_amount": @charge_order.price,
                          "product_code": "QUICK_WAP_PAY"}
        }
        alipay_url = PayRecord.generate_alipay_wap_url2 p1
        order = {pay_type: 1, alipay_url: alipay_url}
      when 3
        #mustpay支付方式
        p1 = {
            return_url: 'h5/users/home',
            notify_url: 'h5/mustpay/notify',
            subject: '充值订单',
            body: '微钻充值订单',
            out_trade_no: @charge_order.code,
            total_fee: @charge_order.price
        }
        prepay_id = PayRecord.generate_prepay_id2 p1
        #pay_url = "/h5/mustpay/pay_order_template?apps_id=#{MUSTAPAYCONFIG[:mustpay][:apps_id]}&prepay_id=#{prepay_id}&subject=充值订单&body=充值&price=#{@charge_order.price}"
        order = {pay_type: 3, apps_id: MUSTAPAYCONFIG[:mustpay][:apps_id], prepay_id: prepay_id}
    end


    return order

  end


  #充值记录
  def self.my_charge_records params
    week = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    current_user = params[:current_user]
    @charge_orders = ChargeOrder.where(status: 1,user_id: current_user.id).order('created_at desc').paginate(:page => params[:page] ||= 1, :per_page => 10)
    return [] if @charge_orders.empty?
    t = @charge_orders.first.created_at.strftime('%Y-%m')
    orders_arr = []
    order_arr_tmp = []
    @charge_orders.each do |order|
      t2 = order.created_at.strftime('%Y-%m')
      w = order.created_at.strftime('%w').to_i
      if t == t2
        order_arr_tmp << {id: order.id, user_id: order.user_id, pay_type: order.pay_type, status: order.status,
                          price: order.price, micro_diamond_amount: order.micro_diamond_amount.to_i, code: order.code,
                          created_year: order.created_at.strftime('%Y年%m月'), created_week: week[w],
                          created_day: order.created_at.strftime('%m-%d'),created_year2: order.created_at.strftime('%Y-%m')}
      else
        t = t2
        orders_arr << order_arr_tmp
        order_arr_tmp = []
        order_arr_tmp << {id: order.id, user_id: order.user_id, pay_type: order.pay_type, status: order.status,
                          price: order.price, micro_diamond_amount: order.micro_diamond_amount.to_i, code: order.code,
                          created_year: order.created_at.strftime('%Y年%m月'), created_week: week[w],
                          created_day: order.created_at.strftime('%m-%d'),created_year2: order.created_at.strftime('%Y-%m')}
      end
    end
    orders_arr << order_arr_tmp
    return orders_arr
  end

  private

  #生成订单号
  def generate_code
    code = Utils.generate_code 'M', self.id
    self.update_attributes({code: code})
  end

  def generate_micro_diamond_amount
    micro_diamond_amount = self.price * SYSTEMCONFIG[:admin_config][:micro_diamond].to_f
    self.update_attributes!(micro_diamond_amount: micro_diamond_amount)
  end
end
