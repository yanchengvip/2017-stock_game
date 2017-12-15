class DaySign < ApplicationRecord
  belongs_to :user

  validates :day, uniqueness: { scope: :user_id, message: "每日只能签到一次" }


  def self.sign!(user)
    if !user.day_signed?
      DaySign.create!(day: Date.today, user_id: user.id, amount: SYSTEMCONFIG[:admin_config][:day_sign][:diamond_account])
    end
  end

  after_create :generate_diamond_account

  private
  def generate_diamond_account
    DiamondAccount.create!(user_id: self.user_id, amount: self.amount, diamond_type: DiamondAccount::DIAMONDTYPE['每日签到赠送'], table_type: 'DaySign', table_id: self.id)
  end
end
