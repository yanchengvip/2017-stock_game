class Betting < ApplicationRecord
  belongs_to :user
  has_many :diamond_accounts, as: :table
  after_create :change_diamond_account_dta

  # bet_type: 0新手第一次，1正常投注，2分享赠送，3每日免费
  # 生成投注数据
  def self.generate_record!(num, user, bet_type, ip)
    day = Date.today
    chests = Betting.get_chest
    odd = chests.sample

    chest = Chest.where(odds: odd, status: 1).first
    num = 10 if bet_type == 2

    return {status: 500, msg: '投注失败，非法数据', data: {}} if ![10,100,500].include?(num)

    left_count = Betting.coin_pool_left
    $redis.incrby("day_betted_coins#{day}", (odd * num).to_i)
    $redis.incrby("day_betted_in_coins#{day}", num)
    if Betting.coin_pool_left < 0
      $redis.decrby("day_betted_coins#{day}", (odd * num).to_i)
      $redis.decrby("day_betted_in_coins#{day}", num)
      return {status: 500, msg: '本日宝箱已开完，请明日再来', data: {}}
    end

    left_chance = Betting.chance_left(user.id)
    $redis.incrby("day_chance_used_user#{user.id}#{day}", 1) if bet_type != 2
    if Betting.chance_left(user.id) < 0
      $redis.decrby("day_chance_used_user#{user.id}#{day}", 1) if bet_type != 2
      return {status: 500, msg: '投注失败，您今天的抽奖次数已用完', data: {}}
    end
    share_times_used = Betting.free_share_times_day(user.id)
    $redis.incrby("share_times_used_day#{user.id}#{day}", 1) if bet_type == 2
    if Betting.free_share_times_day(user.id) < 0
      $redis.decrby("share_times_used_day#{user.id}#{day}", 1) if bet_type == 2
      return {status: 500, msg: '投注失败，您今天分享免费投注次数已用完', data: {}}
    end

    res = {}
    if left_count > 0 && (Betting.chance_left(user.id) >= 0 || (bet_type == 2 && Betting.free_share_times_day(user.id) >= 0))
      begin
        ActiveRecord::Base.transaction do
          # $redis.incrby("day_betted_coins#{day}", (odd * num).to_i)
          # $redis.incrby("day_chance_used_user#{user.id}#{day}", 1) if bet_type != 2
          # $redis.incrby("share_times_used_day#{user.id}#{day}", 1) if bet_type == 2
          cache_betting = $cache.get("give_chest_user#{user.id}")
          betting = Betting.create!(user_id: user.id, amount: num, odds: odd, bet_type: bet_type, request_ip: ip, chest_id: chest&.id, day: day)
          # user.update_attributes!(is_fresh: false) if user.is_fresh 取消了是否新手判断

          if cache_betting && !cache_betting.is_share && bet_type == 2 # 分享赠送
            cache_betting.update_attributes!(is_share: true)
            $cache.set("give_chest_user#{user.id}", nil)
          end
          res = {status: 200, msg: '投注成功', data: { amount: (betting.odds * betting.amount).to_i, odds: betting.odds, user_coin: user.reload.total_diamond_coin.to_i, bet_id: betting.id}}
        end
      rescue Exception => e
        $redis.decrby("day_betted_coins#{day}", (odd * num).to_i)
        $redis.decrby("day_betted_in_coins#{day}", num)
        $redis.decrby("day_chance_used_user#{user.id}#{day}", 1) if bet_type != 2
        $redis.decrby("share_times_used_day#{user.id}#{day}", 1) if bet_type == 2
        $redis.set("day_betted_coins#{day}", nil) if $redis.get("day_betted_coins#{day}").to_i <= 0
        Rails.logger.info("投注失败user#{user.id}day#{day}" + e.to_s)
        res = {status: 500, msg: '系统繁忙，请稍后重试', data: {}}
      end
    else
      res = {status: 500, msg: '本日宝箱已开完，请明日再来', data: {}}
    end

    return res
  end

  # 资金池是否还有剩余
  def self.coin_pool_left
    day = Date.today
    day_coin_pool = $cache.fetch("day_coin_pool", 1 * 3600){
      Setting.day_coin_pool.blank? ? 50000 : Setting.day_coin_pool.to_i
    }
    if $redis.get("day_betted_coins#{day}").blank?
      day_betted_count = Betting.where(day: day).inject(0){|sum, x| sum += (x.odds * x.amount)}.to_i
      $redis.set("day_betted_coins#{day}", day_betted_count, :ex => 3600)
    end

    if $redis.get("day_betted_in_coins#{day}").blank?
      day_betted_in_count = Betting.where(day: day, bet_type: 1).sum('amount')
      $redis.set("day_betted_in_coins#{day}", day_betted_in_count, :ex => 3600)
    end
    divide_count = $redis.get("day_betted_coins#{day}").to_i - $redis.get("day_betted_in_coins#{day}").to_i

    return day_coin_pool - divide_count
     # ? false : true
  end

  # 用户当天还有的次数
  def self.chance_left(userid)
    day = Date.today
    day_chance = $cache.fetch("day_chance", 1 * 3600){
      Setting.day_chance.blank? ? 10 : Setting.day_chance.to_i
    }

    if $redis.get("day_chance_used_user#{userid}#{day}").blank?
      beted_count = Betting.where(user_id: userid, day: day, bet_type: 1).count
      $redis.set("day_chance_used_user#{userid}#{day}", beted_count, :ex => 3600)
    end

    return day_chance - $redis.get("day_chance_used_user#{userid}#{day}").to_i
  end

  # 获得宝箱容器数据
  def self.get_chest
    chests = $cache.fetch("chest_container_now", 1 * 3600){
      Chest.select('odds, total_count').where(status: 1)
    }

    chest_arr = []
    chests.each do |chest|
      chest.total_count.times do
        chest_arr << chest.odds
      end
    end

    return chest_arr.shuffle
  end

  # 新手首次投注赔率
  def self.get_first_chest
    max = $cache.fetch('fresh_odd_max', 10 * 3600){ Setting.fresh_odd_max.to_i }
    min = $cache.fetch('fresh_odd_min', 10 * 3600){ Setting.fresh_odd_min.to_i }
    num = (max - min) / 10 - 1
    chest_arr = [min, max]
    num.times do |i|
      chest_arr << min + (i + 1) * 10
    end

    return chest_arr.map{|cr| (cr * 0.01).round(2)}.shuffle
  end

  def self.free_times_left user
    day = Date.today
    setting_free_times = $cache.fetch("free_times_day#{day}", 3 * 3600){
      Setting.free_times.to_i
    }
    left_times = setting_free_times - Betting.where(user_id: user.id, day: day, bet_type: 3).count

    return left_times
  end

  def self.free_share_times_day userid
    day = Date.today
    free_share_times_day = $cache.fetch("free_share_times_day#{day}", 3 * 3600){
      Setting.free_share_times_day.blank? ? 3 : Setting.free_share_times_day.to_i
    }
    if $redis.get("share_times_used_day#{userid}#{day}").blank?
      share_times_used_day = Betting.where(user_id: userid, day: day, bet_type: 2).count
      $redis.set("share_times_used_day#{userid}#{day}", share_times_used_day, :ex => 3600)
    end
    left_times = free_share_times_day - $redis.get("share_times_used_day#{userid}#{day}").to_i

    return left_times
  end

  # 获得宝箱容器固定赔率数据
  def self.get_chest_odds
    chests = $cache.fetch("chest_odds_container_now", 1 * 3600){
      Chest.select('id, odds').where(status: 1).order(:odds)
    }
    return chests
  end

  private

  def change_diamond_account_dta
    if self.bet_type != 2
      DiamondAccount.create!(user_id: self.user_id, amount: -self.amount, diamond_type: DiamondAccount::DIAMONDTYPE['宝箱投注扣除本金'], table_type: 'Betting', table_id: self.id)
    end

    DiamondAccount.create!(user_id: self.user_id, amount: self.amount * self.odds, diamond_type: DiamondAccount::DIAMONDTYPE['宝箱投注获得奖励'], table_type: 'Betting', table_id: self.id)
  end

end
