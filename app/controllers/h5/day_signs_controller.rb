class H5::DaySignsController < ApplicationController
  skip_before_action :verify_signature
  skip_before_action :verify_authenticity_token


  def create
    return render json: {status: 500, msg: '今日已签到', data: {}} if current_user.day_signed?
    begin
      ActiveRecord::Base.transaction do
        DaySign.sign!(current_user)
        render json: {status: 200, msg: '签到成功', data: {user_coin: current_user.reload.total_diamond_coin.to_i}}
      end
      # render json: {status: 200, msg: '签到成功', data: {user_coin: current_user.reload.total_diamond_coin.to_i}}
    rescue Exception => e
      render json: {status: 500, msg: '签到失败', data: {}}
    end
  end

  # 是否签到接口
  def check
    # user = User.find(params[:user_id]) if params[:user_id]
    # if user.blank? || current_user.id != user.id
    #   return render json: {status: 500, msg: '无权限'}
    # end
    # if user && current_user.id == user.id
    #   return render json: {status: 200, data: user.day_signed?}
    # end
    return render json: {status: 200, data: current_user.day_signed?}
  end

end
