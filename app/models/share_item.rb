class ShareItem < ApplicationRecord
  after_create :share_reward
  private
  def share_reward
    #分享即送钻石币
    if ShareItem.where(user_id: self.user_id).where("created_at > '#{Date.today.to_s}'").lock.count <=SYSTEMCONFIG[:admin_config][:wechat_share][:limit]

      DiamondAccount.create( user_id: self.user_id, amount: SYSTEMCONFIG[:admin_config][:wechat_share][:diamond_account], diamond_type: DiamondAccount::DIAMONDTYPE["每日分享赠送钻币"], table_type: "ShareItem", table_id: self.id)
    end

    if self.controller == "h5/lotteries" && self.share_id  && lottery = Lottery.where(id: self.share_id).first
      lottery.with_lock  do
        if !lottery.win_share && lottery.win_user_id == self.user_id && SYSTEMCONFIG[:admin_config][:winning_share][:diamond_account].to_f > 0
          DiamondAccount.create(user_id: self.user_id, amount: SYSTEMCONFIG[:admin_config][:winning_share][:diamond_account], diamond_type: lottery.product_type == 1 ? DiamondAccount::DIAMONDTYPE["夺宝中奖分享"] : DiamondAccount::DIAMONDTYPE["福袋中奖分享"], table_type: "Lottery", table_id: lottery.id)
          lottery.update_attributes!(win_share: true)
        end
      end
    end
    if self.controller == "h5/gold_gains_histories" && self.action == 'share_prize' && self.user_id && (ranking_config_win = RankingConfigWin.find_by(id: self.share_id))
      begin
        if !ranking_config_win.is_share && ranking_config_win.user_id.to_i == self.user_id
          diamond_type = DiamondAccount::DIAMONDTYPE['排名获奖分享']
          DiamondAccount.create!(user_id: self.user_id, amount: 10, diamond_type: diamond_type)
          ranking_config_win.update_attributes!(is_share: true)
        end
      rescue Exception => e
        Rails.logger.info(e)
      end
    end
    # 宝箱分享赠送一次机会
    if self.controller == "h5/chests" && self.action == 'index' && self.user_id && (betting = Betting.find_by(id: self.share_id)) && !betting.is_share && Betting.free_share_times_day(self.user_id) > 0
      begin
        is_give = $cache.set("give_chest_user#{self.user_id}", betting, 3 * 60)
      rescue Exception => e
        Rails.logger.info(e)
      end
    end

  end
end
