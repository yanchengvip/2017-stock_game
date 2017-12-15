class H5::ChargeOrdersController < ApplicationController
  skip_before_action :verify_signature
  skip_before_action :verify_authenticity_token
  before_action :set_charge_order, only: [:show]

  def index

  end

  def show
    @title = '充值详情'
    respond_to do |format|
      format.html
      format.json { render json: {status: 200, msg: '操作成功', data: {charge_order: @charge_order}} }
    end
  end

  def new
    @title = '充值'
  end


  def create
    @charge_order = ChargeOrder.new(charge_order_params.merge(user_id: current_user.id))
    if @charge_order.save
      p1 = {id: @charge_order.id, pay_type: params[:pay_type]}
      @order = ChargeOrder.pay_charge_order p1
    end
    render json: @order
  end

  def my_charge_record
    @title = '充值记录'
    @charge_orders = ChargeOrder.my_charge_records({current_user: current_user, page: 1})
  end

  def my_charge_record_page
    @title = '充值记录'
    @charge_orders = ChargeOrder.my_charge_records({current_user: current_user, page: params[:page]})
    render json: {status: 200,msg: '操作成功',data: {charge_orders: @charge_orders.as_json}}
  end

  def my_micro_diamond_record
    @title = '微钻账单'
    @micro_records = MicroDiamondAccount.my_micro_record({current_user: current_user})
  end


  def my_micro_diamond_record_page
    @title = '微钻账单'
    @micro_records = MicroDiamondAccount.my_micro_record({current_user: current_user,page: params[:page]})
    render json: {status: 200,msg: '操作成功',data: {micro_records: @micro_records.as_json}}
  end

  private

  def set_charge_order
    @charge_order = ChargeOrder.where(id: params[:id],user_id: current_user.id).first
  end


  def charge_order_params
    params.permit(:user_id, :status, :price)
  end
end
