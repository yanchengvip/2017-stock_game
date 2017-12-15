class AddRequestIpToRankingConfigWins < ActiveRecord::Migration[5.0]
  def change
    add_column :ranking_config_wins, :request_ip, :string, comment: "用户ip"
  end
end
