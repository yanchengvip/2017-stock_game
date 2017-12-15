module Admins
  module RankingConfigHelper
    extend ActiveSupport::Concern

    #类方法
    module ClassMethods

    end

    #竞赛排名，保存排行对应的奖品
    def award_manage_save params
      self.update_attributes(status: -1)
      ranking_config = RankingConfig.create(ranking: self.ranking, date_type: self.date_type,
                                            ranking_type: self.ranking_type, status: 1)

      award_name = []
      #无奖品
      if params[:empty_award].to_i == 1
        #  self.ranking_config_items.each do |rci|
        #   rci.destroy()
        # end
        award_name << '无奖品'
      end

      #虚拟资金
      if params[:virtual_money].to_i == 2
        ranking_config.ranking_config_item_save params[:virtual_money_v], 2, ''
        award_name << '虚拟资金:' + params[:virtual_money_v]
      end

      #钻石币
      if params[:diamond_money].to_i == 3
        ranking_config.ranking_config_item_save params[:diamond_money_v], 3, ''
        award_name << '钻石币:' + params[:diamond_money_v]
      end

      #现金
      if params[:real_money].to_i == 7
        ranking_config.ranking_config_item_save params[:real_money_v], 7, ''
        award_name << '现金:' + params[:real_money_v]
      end


      #夺宝商品
      if params[:lottery_product].to_i == 4
        response = ranking_config.ranking_config_item_save params[:lottery_product_v], 4, params[:lottery_product_v]
        award_name << '夺宝商品:' + response.name
      end

      #分享福袋
      if params[:lucky_bag].to_i == 5
        response = ranking_config.ranking_config_item_save params[:lucky_bag_v], 5, params[:lucky_bag_v]
        award_name << '分享福袋:' + response.name
      end

      #分享钻石包
      if params[:diamond_bag].to_i == 6

      end

      ranking_config.update_attributes(award_name: award_name.join('、'))
      return true
    end


    def ranking_config_item_save price, prize_type, product_id

      if [2, 3, 7].include? prize_type
        self.ranking_config_items.create(price: price, prize_type: prize_type)
      end

      if [4, 5].include? prize_type
        product = Product.find(product_id)
        product.ranking_config_items.create(ranking_config_id: self.id, prize_type: prize_type)
      end

      return product

    end


  end
end