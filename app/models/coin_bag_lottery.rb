class CoinBagLottery < ApplicationRecord
  belongs_to :coin_bag
  has_many :coin_bag_lottery_items,dependent: :destroy
  after_create :generate_share_code
  after_create :cal_coin_count_groups
  belongs_to :user

  def get_cron_count
    if  self.end_time >= Time.now && res = $redis.lpop("coin_bag_lottery:#{self.id}")
      res
    else
      nil
    end
  end

  def generate_share_code
    self.update_attributes({share_code: Utils.generate_uuid})
  end

  def cal_coin_count_groups
    groups = Array.new(self.person_count, 1)
    rc = self.coin_count - self.person_count
    self.person_count.times do |i|
      if rc > 0
        c = rand(rc/2)
        groups[i] += c
        rc -= c
      end
    end
    groups[rand(self.person_count)] +=  rc
    $redis.rpush("coin_bag_lottery:#{self.id}", groups)
    self.update_attributes({coin_count_groups: groups.join(",")})
  end

end
