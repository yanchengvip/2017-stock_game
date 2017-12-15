class H5::TradeBoxsController < ApplicationController
  skip_before_action :verify_signature
  skip_before_filter :verify_authenticity_token

  def create
    diamond_trade_count = current_user.diamond_trades.where("created_at > '#{Time.now.beginning_of_day}'").count
    if diamond_trade_count >= SYSTEMCONFIG["admin_config"]["box"]["trade_count"]
      trade_box = TradeBox.create(user_id: current_user.id, amount: SYSTEMCONFIG["admin_config"]["box"]["gold"], day: Date.today.to_s)

      if trade_box.save
        render json: {status: 200, msg:"打开宝箱", data: current_user.reload.total_diamond_coin.to_i}
      else
        render json: {status: 500, msg: "已经打开"}
      end

    else
      render json: {status: 500, msg:"当前交易次数#{diamond_trade_count}， 打开宝箱需要#{SYSTEMCONFIG['admin_config']['box']['trade_count']}次"}
    end
  end
end
