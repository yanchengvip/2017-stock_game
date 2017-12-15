class CreateRankingConfigWins < ActiveRecord::Migration[5.0]
  def change
    create_table :ranking_config_wins do |t|
      t.string :user_id
      t.datetime :lottery_time
      t.integer :ranking_config_id

      t.timestamps
    end
  end
end
