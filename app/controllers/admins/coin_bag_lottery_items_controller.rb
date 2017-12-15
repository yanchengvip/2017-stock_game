class Admins::CoinBagLotteryItemsController < Admins::ApplicationController


  private

    def set_coin_bag_lottery_item
      @coin_bag_lottery_item = CoinBagLotteryItem.find(params[:id])
    end


    def coin_bag_lottery_item_params
      params.require(:coin_bag_lottery_item).permit(:coin_bag_lottery_id, :coin_bag_id, :user_id, :request_ip, :coin_count)
    end
end
