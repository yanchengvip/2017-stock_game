#0：默认值,1：吃贡,2:进贡,
class PayTribute < ApplicationRecord
  has_many :diamond_accounts, as: :table
  belongs_to :tribute_user, class_name: 'User', foreign_key: 'tribute_user_id'
  belongs_to :user
  validates_uniqueness_of :user_id, scope: [:tribute_user_id, :share_user_id, :tribute_type, :week, :year]

  #根据周收益，计算进贡
  #朋友圈内周收益排行第一,朋友圈内非第一则进贡,当周收益相同时邀请者优先,当周收益相同时注册时间早者优先
  def self.pay_tribute_count

    if Date.today.wday != 6
      return '仅周六执行'
    end
    share_user_ids = User.select(:share_user_id).distinct.pluck(:share_user_id)
    share_user_ids.delete(0)
    share_user_ids.each do |share_user_id|
      @users = User.select('users.*', 'ggw.amount as week_amount')
                   .joins("left join gold_gains_weeks as ggw on ggw.user_id = users.id and ggw.week = #{Date.today.cweek} and ggw.year = #{Time.now.year}")
                   .where('share_user_id = ? or users.id = ?', share_user_id, share_user_id)
                   .order('ggw.amount desc', 'users.created_at asc')
      user_ids = @users.pluck(:id)
      chigong_id = @users.first.id #吃贡的用户ID
      index = user_ids.index(share_user_id)
      ggw_amounts = @users.pluck('ggw.amount')
      owner_week_amount = ggw_amounts[index] #群主的周收益
      if owner_week_amount == ggw_amounts[0]
        #当周收益相同时邀请者优先
        chigong_id = share_user_id
      end
      user_ids.delete(chigong_id) #进贡的用户ID

      add_pay_tribute_record chigong_id, user_ids, share_user_id
    end
  end


  #朋友圈本周收益排行
  def self.current_week_gold_gain_rank current_user

    $cache.fetch("friend_circle_rank#{current_user.id}", 60*5) {
      #被邀请的朋友圈
      other_circle_rank_ids = User.select('users.id', 'users.nickname', 'users.headimgurl', 'users.phone', 'users.created_at', 'ggw.amount as week_amount')
                                  .joins("left join gold_gains_weeks as ggw on ggw.user_id = users.id and ggw.week = #{Date.today.cweek} and ggw.year = #{Time.now.year}")
                                  .where('share_user_id = ? or users.id = ?', current_user.share_user_id,current_user.share_user_id)
                                  .order('ggw.amount desc', 'users.created_at asc').pluck(:id)
      share_user = User.where(id: current_user.share_user_id).first
      rank = other_circle_rank_ids.index(current_user.id).to_i + 1 #被邀请的朋友圈的名次
      other_circle_rank = {share_user: share_user, ranking: rank}
      #自己创建的朋友圈
      my_circle_rank = User.select('users.id', 'users.nickname', 'users.headimgurl', 'users.phone', 'users.created_at', 'ggw.amount as week_amount')
                           .joins("left join gold_gains_weeks as ggw on ggw.user_id = users.id and ggw.week = #{Date.today.cweek} and ggw.year = #{Time.now.year}")
                           .where('share_user_id = ? or users.id = ?', current_user.id, current_user.id)
                           .order('ggw.amount desc', 'users.share_user_id asc', 'users.created_at asc')

      #上周自己朋友圈，排行第一的用户信息
      last_week_user = PayTribute.select('users.id as user_id', 'users.nickname', 'users.headimgurl', 'users.phone', 'sum(pay_tributes.amount) as sum_week_amount')
                           .joins("left join users on pay_tributes.user_id = users.id")
                           .where(share_user_id: current_user.id, tribute_type: 1, week: Date.today.cweek - 1, year: Time.now.year)
                           .group('pay_tributes.user_id')


      @friend_circle_rank = {
          other_circle: other_circle_rank.as_json,
          my_circle: my_circle_rank.as_json,
          last_week_user: last_week_user.as_json,
      }
    }

  end


  #邀请好友注册后，清空cache
  def self.clear_friend_circle current_user
    $cache.set "friend_circle_rank#{current_user.id}", nil
  end

  private

  def self.add_pay_tribute_record chigong_id, jingong_ids, share_user_id

    begin

      ActiveRecord::Base.transaction do
        jingong_ids.each do |jingong_id|
          user = User.find(jingong_id)
          total_amount = user.total_assets.to_f + user.total_diamond_coin #进贡者=模拟盘总资产+钻石币
          if total_amount > 20000
            #模拟盘总资产+钻石币，小于等于本金20000时不进贡
            #扣除钻石币进贡，钻石币可扣除为负值
            jingong_amount = (total_amount.to_f - 20000) * 0.05
            #吃贡
            tribute_atrr = {user_id: chigong_id, tribute_user_id: jingong_id, amount: jingong_amount, share_user_id: share_user_id,
                            tribute_type: 1, week: Date.today.cweek, year: Time.now.year}
            pay1 = PayTribute.create!(tribute_atrr)

            #进贡  amount 负数
            tribute_atrr2 = {user_id: jingong_id, tribute_user_id: chigong_id, amount: -jingong_amount, share_user_id: share_user_id,
                             tribute_type: 2, week: Date.today.cweek, year: Time.now.year}
            pay2 = PayTribute.create!(tribute_atrr2)

            pay1.diamond_accounts.create!(user_id: pay1.user_id, amount: pay1.amount, diamond_type: 36)
            pay2.diamond_accounts.create!(user_id: pay2.user_id, amount: pay2.amount, diamond_type: 35)
          end

        end

      end

    rescue Exception => e
      Rails.logger.info('朋友圈进贡-------------' + e.to_s)
    end

  end

end

