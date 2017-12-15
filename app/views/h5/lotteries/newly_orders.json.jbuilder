json.status 200
json.msg '操作成功'
json.data do
  json.array! @new_ten_orders do |new_ten_order|
    # json.extract! new_ten_order, :id, :nickname, :phone, :topic_id, :reply_count
    #json.url api_comment_url(comment, format: :json)
    json.id new_ten_order.id
    # json.lottery_id new_ten_order.lottery_id
    # json.created_at ((Time.now - new_ten_order.created_at)/60).to_i
    # json.created_at win_time_show(new_ten_order)
    json.lottery_time win_time_show(new_ten_order)
    # json.showname filter_string(new_ten_order.user.nickname) || filter_string(new_ten_order.user.phone)
    json.win_user do
      json.nickname new_ten_order.win_user.nickname
      json.phone new_ten_order.win_user.phone
    end
    json.product do
      json.name new_ten_order.product.name
    end
  end
end

