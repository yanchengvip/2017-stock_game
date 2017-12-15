class RankingConfigItem < ApplicationRecord
  belongs_to :ranking_config
  belongs_to :table, polymorphic: true


  # 根据奖励类型生成订单
  def generate_orders!(ranking_config_win)
    ranking_config = self.ranking_config
    case prize_type
    when 2
      # 增加虚拟资金，GoldAccount
      account_type = GoldAccount::ACCOUNTTYPE[RankingConfig::DATETYPE[ranking_config.date_type]]
      GoldAccount.create!(user_id: ranking_config_win.user_id, amount: self.price, account_type: account_type,
                                       table_type: 'RankingConfigWin', table_id: ranking_config_win.id, available_gold_amount: self.price)
    when 3
      # 钻石币，DiamondAccount
      diamond_type = DiamondAccount::DIAMONDTYPE[RankingConfig::DATETYPE[ranking_config.date_type]]
      DiamondAccount.create!(user_id: ranking_config_win.user_id, amount: self.price, diamond_type: diamond_type)
    when 4
      # 夺宝商品 RankingConfigWinOrder
      product = self.table
      # 字段具体取值可能需要详细探讨
      RankingConfigWinOrder.create!(ranking_config_item_id: self.id, ranking_config_win_id: ranking_config_win.id,
                                                                      user_id: ranking_config_win.user_id, status: 0, product_id: product.id, total_count: product.total_count,
                                                                      total_price: product.price, address_id: (ranking_config_win.user.addresses.default.id rescue nil),
                                                                      request_ip: ranking_config_win.request_ip)

    when 5
      # 分享福袋 lotteries
      product = self.table
      # status 取值待定
      lottery =  product.lotteries.new(product_id: product.id, published_at: Time.now, product_name: product.name, total_count: product.total_count,
                                                      price: product.price, status: 0, lottery_time: Time.now, award: product.award, end_time: product.end_time, 
                                                      user_id: ranking_config_win.user_id)
      ranking_config_win.update!(lottery_id: lottery.id) if lottery.save

    when 6
      # 钻石礼包7，暂时没有
    when 7
      # 现金，暂时没有
    end
      
  end
end
