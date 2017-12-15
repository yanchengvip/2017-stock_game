class H5::AddressesController < ApplicationController
  skip_before_action :verify_signature
  skip_before_action :verify_authenticity_token
  before_action :set_address, only: [:edit, :update, :address_set_default, :destroy]

  def index
    @title = '地址管理'
    @addresses = current_user.addresses.order('is_default desc')
    respond_to do |format|
      format.html { render 'h5/addresses/index' }
      format.json { render json: {status: 200, msg: '操作成功', data: {addresses: @addresses.as_json}} }
    end
  end

  def edit
    @title = '地址修改'
  end


  def update

    flag = @address.update_attributes(address_params)
    if flag
      msg = {status: 200, msg: '操作成功', data: {address: @address.as_json}}
    else
      msg = {status: 500, msg: '操作失败', data: {address: @address.as_json}}
    end
    render json: msg
  end


  def new
    @title = '添加地址'
  end

  def create
    @title = '添加地址'
    address = current_user.addresses.new(address_params)
    if address.save
      msg = {status: 200, msg: '操作成功', data: {address: address.as_json}}
    else
      msg = {status: 500, msg: '操作失败', data: {address: address.as_json}}
    end
    render json: msg
  end


  def destroy
    @address.update_attributes(status: -1)
    render json: {status: 200, msg: '操作成功', data: {address: ''}}
  end

  #默认地址
  def address_set_default
    #binding.pry
    flag = false
    if params[:set_status].to_i == 1
      flag = @address.update_attributes!(is_default: true)
    elsif params[:set_status].to_i == 2
      flag = @address.update_attributes(is_default: false)
    end
    if flag
      msg = {status: 200, msg: '操作成功', data: {address: @address.as_json}}
    else
      msg = {status: 500, msg: '操作失败', data: {address: @address.as_json}}
    end
    render json: msg
  end


  private

  def set_address
    @address = Address.where(id: params[:id],user_id: current_user.id,status: 0).first
  end

  def address_params
    params.permit(:user_name, :phone, :postcode, :address, :is_default)
  end
end
