json.set! :data do
  json.array! @lottery_orders do |lottery_order|
    # json.extract! new_ten_order, :id, :nickname, :phone, :topic_id, :reply_count
    #json.url api_comment_url(comment, format: :json)
    json.id lottery_order.id
    json.is_win lottery_order.is_win #是否中奖
    json.status_str order_status_str(lottery_order)[:str] #订单状态
    json.lottery_status_str lottery_status_str(lottery_order.lottery) # user_id 如果不空，为中奖用户id
    json.created_at time_str(lottery_order.created_at) #抽奖时间
    json.product_price (lottery_order.lottery.total_count * lottery_order.lottery.price * (1 - SYSTEMCONFIG[:lottery_system_persent].to_f)).to_i #兑换商品时对应的商品价值
    json.codes code_show(lottery_order.lottery_order_items) #本次抽奖的号码
    json.count lottery_order.total_count #参与人次

    json.lottery do
      json.id lottery_order.lottery.id
      json.status lottery_order.lottery.status #夺宝期次状态
      json.lottery_code lottery_order.lottery.lottery_code #期号
      json.take_award lottery_order.lottery.take_award #是否领奖
      # json.lottery_time win_time_show(lottery_order.lottery) #揭晓时间
    end
    # json.lottery_order_items do
    # end
    json.product do
      json.id lottery_order.lottery.product.id
      json.head_image lottery_order.lottery.product.head_image #商品图片
      json.product_type lottery_order.lottery.product.product_type #商品类型, 1夺宝产品, 2福袋产品
      # json.name lottery_order.lottery.product.name
    end

  end
end
json.status 200
json.msg '操作成功'
