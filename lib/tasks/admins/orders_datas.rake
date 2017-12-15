
def ranking_config_win_order_seed

  # RankingConfigWinOrder.delete_all

  RankingConfigWinOrder.create(
       id: 1,
       ranking_config_item_id: 3,
       ranking_config_win_id: 1,
       user_id: 100,
       status: 0,
       product_id: 1
  )

  RankingConfigWinOrder.create(
      id: 2,
      ranking_config_item_id: 4,
      ranking_config_win_id: 2,
      user_id: 100,
      status: 0,
      product_id: 1
  )

end


