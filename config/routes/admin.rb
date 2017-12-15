Rails.application.routes.draw do
  #管理员后台
  namespace :admins do

    root 'homes#index'
    get 'login', to: 'sessions#index'
    get 'logout', to: 'sessions#logout'


    resources :products do
      collection do
        post 'destroy_product'
        post 'update_product'
        post 'search'
        get 'search'
      end
    end
    resources :images do
      collection do
        post 'pro_thumb_upload'
        post 'update_img'
        post 'add_img'
      end
    end

    resources :homes do
      collection do
        get 'tj_more'
      end

    end
    resources :sessions
    resources :sale_diamonds do
      collection do
        get 'detail'
      end
    end

    resources :lottery_orders do
      collection do
        post 'update_status'
        post 'search'
        get 'search'
      end
    end


    resources :lottery_order_items
    resources :lotteries do
      collection do
        post 'search'
        get 'search', to: 'index'
        post 'set_sort'
        post 'update_lottery'
        post 'auto_extension_lottery'
      end
    end

    resources :lucky_bags do
      collection do
        get 'bags_to_user'
        get 'lottery_list'
        get 'lottery_details'
        get 'win_items'
        get 'setting'
        get 'manage_order'
        post 'destroy_bag'
        post 'bag_selected_user'
        post 'search'
        get 'search'
        post 'search_lottery_list'
        get 'search_lottery_list'
        post 'search_win_items'
        get 'search_win_items'
        get 'search_unselected_users'
      end
    end

    resources :users do
      collection do
        get 'admins_list'
        get 'my_info'
        post 'update_password'
        get 'users_list'
        get 'add_roles_for_user'
        post 'add_roles_for_user'
        post 'users_list'
        post 'forget_password_update'
        get 'qrcodes'
        get 'generate_qrcode'
        post 'qrcodes_destroy'
        post 'admin_update'
      end

    end


    resources :ranking_configs do
      collection do
        get 'earning_manage'
        get 'rate_manage'
        get 'award_manage'
        post 'award_manage_save'
      end
    end

    resources :ranking_config_wins do
      collection do
        get 'earning_record'
        get 'rate_record'
        post 'earning_record'

      end
    end
    resources :ranking_config_items

    resources :ranking_config_win_orders do
      collection do
        post 'manage'
      end

    end

    resources :coin_bag_lottery_items
    resources :coin_bag_lotteries
    resources :coin_bags do
      collection do
        get 'coins_to_user'
        post 'coins_to_user_save'
        post 'destroy_coin'
        post 'search'
        get 'search'
        get 'search_unselected_users'
      end
    end

    resources :download_csv do
      collection do
        get 'user_info_csv'
        get 'remain_balance_csv'
        get 'change_balance_csv'
        get 'month_money_csv'
        get 'show_user_info'
        get 'show_remain_balance'
        get 'show_change_balance'
        get 'show_month_money'
        get 'download_csv_file'
        get 'show_remain_balance_data_diff'
        get 'recovery_remain_balance_data_diff'
        get 'show_lottery_orders'
        get 'lottery_orders_csv'
        get 'show_channel'
        get 'channel_detail'
      end
    end

    resources :share_configs do
      collection do
        post :share_delete
        post :share_update
      end
    end

    resources :other_manages

    resources :chests do
      member do
        post :disable
      end
    end
    resources :settings, only: [:index] do
      collection do
        put :update_sets
      end
    end

    resources :product_tags do
      collection do
        post 'tag_delete'
        post 'tag_update'
      end
    end

    resources :resources do
      collection do
        post 'resource_update'
        post 'resource_delete'
        get 'get_all_actions'
        get 'get_all_controllers'
      end

    end

    resources :micro_diamond_bags do
      collection do
        post :update_micro
        post :destroy_micro
        get  :finish_list
        get :micro_setting
      end
    end

  end
end
