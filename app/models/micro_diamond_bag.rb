class MicroDiamondBag < ApplicationRecord
  validates :published_at,presence: true
  validates :buy_at,presence: true
  has_many :micro_diamond_bag_items
  after_create :redis_init
  #开红包
  def open_result(current_user, request_ip)
    res = {}
    current_user.with_lock do
      if current_user.total_diamond_coin > self.buy_diamond_amount
        if !MicroDiamondBagItem.where(user_id: current_user.id, micro_diamond_bag_id: self.id).exists?
          if (left_count = $redis.decrby("micro_diamond_bag:#{self.id}", 1)) >= 0
            if $redis.sadd("micro_diamond_bag_#{self.id}", current_user.id)
              amount = $redis.lpop("micro_diamond_bag_queue_#{self.id}")
              if amount
                micro_diamond_bag_item = self.micro_diamond_bag_items.create(user_id: current_user.id, amount: amount, request_ip: request_ip)
                current_user.diamond_accounts.create!(amount: -self.buy_diamond_amount, diamond_type:  DiamondAccount::DIAMONDTYPE["微钻红包"], table_type: "MicroDiamondBagItem", table_id: micro_diamond_bag_item.id )
                current_user.micro_diamond_accounts.create!(micro_type: MicroDiamondAccount::MICROTYPE["微钻红包"], amount: amount, table_type: "MicroDiamondBagItem", table_id:  micro_diamond_bag_item.id)
                if left_count == 0
                  self.update(status: 2)
                end
                res = {status: 200, data:{micro_diamond_bag_item: micro_diamond_bag_item}}
              else
                self.redis_init()
                $redis.srem("micro_diamond_bag_#{self.id}", current_user.id)
                res = {status: 500, msg: "系统繁忙，请稍后重试1"}
              end
            else
              res = {status: 500, msg: "系统繁忙，请稍后重试2"}
            end
          else
            res = {status: 500, msg: "手慢了，微钻被抢光了"}
          end
        else
          res = {status: 500, msg: "红包只能开一次"}
        end
      else
        res = {status: 500, msg: "钻币不足"}
      end
    end
    return res
  end

  #初始化微钻数据
  def self.cal_micro_diamond_count_groups(total_count, person_count)
    if total_count < person_count || total_count <= 0 || person_count <= 0
      return false
    end
    groups = Array.new(person_count, 1)
    rc = total_count - person_count
    person_count.times do |i|
      if rc > 0
        c = rand(rc/(person_count - i)).to_i
        groups[i] += c
        rc -= c
      end
    end
    groups[rand(person_count)] +=  rc
    groups.shuffle
  end

  #红包数据初始化
  def redis_init
    if($redis.sadd("micro_diamond_bag_redis_initing_#{self.id}", self.id))
      $redis.set("micro_diamond_bag:#{self.id}", self.person_count - self.micro_diamond_bag_items.count)
      user_ids = self.micro_diamond_bag_items.pluck(:user_id)
      $redis.sadd("micro_diamond_bag_#{self.id}", user_ids) if user_ids.size > 0
      groups = MicroDiamondBag.cal_micro_diamond_count_groups(self.micro_diamond_amount - self.micro_diamond_bag_items.sum(:amount), self.person_count - self.micro_diamond_bag_items.count )
      if groups
        groups.each_slice(100).to_a.each do |group|
          $redis.lpush("micro_diamond_bag_queue_#{self.id}", groups)
        end
      end
      $redis.expire("micro_diamond_bag_redis_initing_#{self.id}", 1)
    else
    end
  end
  #红包数据清空
  def redis_clear
  end


end

