class Admins::CoinBagLotteriesController < Admins::ApplicationController

  private

    def set_coin_bag_lottery
      @coin_bag_lottery = CoinBagLottery.find(params[:id])
    end


    def coin_bag_lottery_params
      params.require(:coin_bag_lottery).permit(:coin_bag_id, :user_id, :share_code)
    end
end
