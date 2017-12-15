class H5::ChestsController < ApplicationController

  def index
    @title = '钻石大宝箱'

    @is_give = $cache.get("give_chest_user#{current_user.id}")
    @user_chance = Betting.chance_left(current_user.id)
    @free_share_left = Betting.free_share_times_day(current_user.id)
    @odds = Betting.get_chest_odds

    respond_to do |format|
      format.html
      format.json { render json: {data: {is_give: @is_give&.id, user_chance: @user_chance, free_share_left: @free_share_left, odds: @odds.map(&:odds)}, status: 200, msg: '操作成功'} }
    end
  end


end
