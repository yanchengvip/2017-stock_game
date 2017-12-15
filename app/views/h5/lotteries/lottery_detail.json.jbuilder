json.status 200
json.msg '操作成功'
json.set! :data do
  json.lottery @lottery.as_json
  json.win_user_total_buy @total_buy
  json.self_lottery_order_items @self_lottery_order_items
  if @product.product_type == 1
    json.product_images @product.images.map{|image| SYSTEMCONFIG[:cdn_host]+image.url}
  end
  if @product.product_type == 2
    json.product_image SYSTEMCONFIG[:cdn_host]+@product.head_image
  end

  json.can_lottery @can_lottery
  json.lottery_max_total_count @lottery.max_total_count
  json.lotteried_count $redis.get("lottery_count:#{@lottery.id}:#{current_user.id}").to_i
  # json.user_left_count @user_left_count
  json.max_count @max_count
  # json.lottery_user_count (current_user.total_diamond_coin / @lottery.price).floor
end
