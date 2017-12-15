class AddParticipantTimeToLotteries < ActiveRecord::Migration[5.0]
  def change
    add_column :lotteries, :participant_time, :integer, comment: "获奖用户参与次数", default: 0
  end
end
