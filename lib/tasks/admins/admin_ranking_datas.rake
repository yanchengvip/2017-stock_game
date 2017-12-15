


#竞赛排名


def ranking_award_seed
  #收益奖品设置
  # RankingConfig.delete_all
  #收益奖品设置
  #日
  RankingConfig.create(
      id: 1 ,
      ranking: 1,
      date_type: 1,
      ranking_type: 1
  )

  RankingConfig.create(
      id: 2,
      ranking: 2,
      date_type: 1,
      ranking_type: 1
  )

  RankingConfig.create(
      id: 3,
      ranking: 3,
      date_type: 1,
      ranking_type: 1
  )

  #周
  RankingConfig.create(
      id: 4 ,
      ranking: 1,
      date_type: 2,
      ranking_type: 1
  )

  RankingConfig.create(
      id: 5,
      ranking: 2,
      date_type: 2,
      ranking_type: 1
  )

  RankingConfig.create(
      id: 6,
      ranking: 3,
      date_type: 2,
      ranking_type: 1
  )


  #月
  RankingConfig.create(
      id: 7 ,
      ranking: 1,
      date_type: 3,
      ranking_type: 1
  )

  RankingConfig.create(
      id: 8,
      ranking: 2,
      date_type: 3,
      ranking_type: 1
  )

  RankingConfig.create(
      id: 9,
      ranking: 3,
      date_type: 3,
      ranking_type: 1
  )


  #年
  RankingConfig.create(
      id: 10 ,
      ranking: 1,
      date_type: 4,
      ranking_type: 1
  )

  RankingConfig.create(
      id: 11,
      ranking: 2,
      date_type: 4,
      ranking_type: 1
  )

  RankingConfig.create(
      id: 12,
      ranking: 3,
      date_type: 4,
      ranking_type: 1
  )

end


def ranking_rate_seed
  #收益率奖品设置


  #日
  RankingConfig.create(
      id: 13 ,
      ranking: 1,
      date_type: 1,
      ranking_type: 2
  )

  RankingConfig.create(
      id: 14,
      ranking: 2,
      date_type: 1,
      ranking_type: 2
  )

  RankingConfig.create(
      id: 15,
      ranking: 3,
      date_type: 1,
      ranking_type: 2
  )

  #周
  RankingConfig.create(
      id: 16 ,
      ranking: 1,
      date_type: 2,
      ranking_type: 2
  )

  RankingConfig.create(
      id: 17,
      ranking: 2,
      date_type: 2,
      ranking_type: 2
  )

  RankingConfig.create(
      id: 18,
      ranking: 3,
      date_type: 2,
      ranking_type: 2
  )


  #月
  RankingConfig.create(
      id: 19 ,
      ranking: 1,
      date_type: 3,
      ranking_type: 2
  )

  RankingConfig.create(
      id: 20,
      ranking: 2,
      date_type: 3,
      ranking_type: 2
  )

  RankingConfig.create(
      id: 21,
      ranking: 3,
      date_type: 3,
      ranking_type: 2
  )


  #年
  RankingConfig.create(
      id: 22 ,
      ranking: 1,
      date_type: 4,
      ranking_type: 2
  )

  RankingConfig.create(
      id: 23,
      ranking: 2,
      date_type: 4,
      ranking_type: 2
  )

  RankingConfig.create(
      id: 24,
      ranking: 3,
      date_type: 4,
      ranking_type: 2
  )

end


#raking_config_items

def ranking_config_items_seed

  # RankingConfigItem.delete_all
  RankingConfigItem.create(
      id: 1,
      ranking_config_id: 1,
      price: 100,
      prize_type: 2
  )

  RankingConfigItem.create(
      id: 2,
      ranking_config_id: 13,
      price: 100,
      prize_type: 2
  )

  RankingConfigItem.create(
      id: 3,
      ranking_config_id: 1,
      price: 0,
      table_type: 'Product',
      table_id: 1,
      prize_type: 4
  )

  RankingConfigItem.create(
      id: 4,
      ranking_config_id: 13,
      price: 0,
      table_type: 'Product',
      table_id: 1,
      prize_type: 4
  )


end


def ranking_config_win_seeds

    # RankingConfigWin.delete_all

    RankingConfigWin.create(
          id: 1,
          user_id: 100,
          lottery_time: Time.new,
          ranking_config_id: 3
    )

    RankingConfigWin.create(
        id: 2,
        user_id: 100,
        lottery_time: Time.new,
        ranking_config_id: 13
    )
end
