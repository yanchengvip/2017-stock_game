Rails.application.routes.draw do
  namespace :h5 do
    root to: "lotteries#index"

    resources :hold_diamonds, only:[:index]

    resources :micro_diamond_bags, only:[:index, :show] do
      collection do
        get :old_bags
        get :open
        post :micro_diamond_bag_items
      end
    end

    resources :posts, only:[] do
      collection do
        get :diamond_account_role
      end
    end
    resources :lotteries, only:[:index, :show] do
      member do
        get :lucky_package_open
        get :lucky_package_join
        post :take_award
        get :receive_prizes
        get :share_prize
        get :machine
        get :detail
        get :choose_address
        get :reward_detail
        get :next_step
        post :set_consign_add
      end
      collection do
        get :buy_record
        get :lucky_package
        get :lucky_package_share
        get :formula_detail
        get :buy_record_append
        post :alert_get_diamond
        get :newly_orders
        get :buy_record_page
        get :lottery_detail
      end
    end
    resources :coin_bag_lotteries, only:[:index] do
      member do
        get :share
        get :share_open
        get :share_open_result
      end
    end
    resources :lottery_orders, only:[:index, :create] do
      collection do
        get 'self_lottery_orders'
      end
    end

    resources :products, only:[:show]

    resources :trade_boxs, only:[:create]

    resources :sale_diamonds, only:[:show] do
      member do
        get :buy
        get :sell
        get :shorting
        get :close
        get :diamond_history_price
      end
      collection do
        get :diamond_history_close_price
        get :next
        get :pre
        get :kline
        get :update_diamonds_price
      end
    end
    resources :diamond_trades, only:[:create] do
      member do
      end
      collection do
      end
    end
    resources :booking_trades, only:[:index, :create] do
      member do
      end
      collection do
        post :cancle
      end
    end

    resources :users, only:[:update] do
      member do
        get :binding_phone
        get :get_verification_code
        get :invite_history
        post :exec_coin
        post :change_avatar
        get :check_diamond_coin
        # 接口
        get :diamond_coin_api
      end
      collection do
        post :alert_binding_phone
        get :init_diamond_info
        post :send_code
        get :verify_code
        get :home
        get :modify_password
        get :law_illustration
        get :invite_history_page
        get :my_all_record
        get :my_profile
        get :nickname_new
        post :nickname_update
      end
    end

    resources :diamond_trades, only:[:index]

    # resources :gold_gains_histories, only: [:index] do
    resources :gold_gains_histories, only: [:index] do
      member do
      end
      collection do
        get :currency_description
        get :rank_detail
        get :rank_rate_detail
        get :share_prize
        post :get_gain
        get :friend_circle_record
        get :receive_prizes
      end
    end


    resources :alipay do
      collection do
        get :pay_extra
        post :notify
        get :alipay_by_wap
        get :test
      end

    end

    resources :mustpay do
      collection do
        get 'pay_order'
        post 'notify'
      end

    end
    # match '/login', to: 'session#login', via:[:get]

    resources :chests, only: [:index]
    resources :bettings, only: [:index, :create] do
      member do
        get :share_prize
      end
      collection do
      end
    end
    resources :day_signs, only: [:create]

    # resources :charge_orders do
    #   collection do
    #     get :my_charge_record
    #     get :my_charge_record_page
    #     get :my_micro_diamond_record
    #     get :my_micro_diamond_record_page
    #   end
    # end


    resources :diamond_accounts do

      collection do
        get :my_diamond_account_record
        get :my_diamond_account_record_page
      end
    end

    resources :addresses do
      collection do
        post :address_set_default
      end
    end

  end
end
