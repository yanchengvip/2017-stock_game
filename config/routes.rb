Rails.application.routes.draw do


  get 'api/wx_auth'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  match "/phone_code", to: "home#phone_code", via:[:get]

  resources :couriers
  resources :addresses
  # resources :gold_gains_histories
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
  draw :h5
  draw :admin
  match "/share", to: "home#share", via:[:get]
  match "/home/share_open", to: "home#share_open", via:[:get]
  get "home/get_diamond"
  get "home/get_diamonds"
  get 'home/pending_trade'
  get 'home/buy'
  get 'home/index'
  get 'home/market'
  post "home/share_callback"
  get 'home/user_info_api'

  get 'session/register'
  get 'session/login'
  get 'get_pwd' => "session#get_pwd"
  get 'agreement' => 'session#agreement'

  post 'session/create'
  post 'session/auth'
  post 'session/send_verification_code'
  post "session/send_verification_code_with_rucaptcha"

  match '/login', to: 'session#login', via:[:get]
  match '/register', to: 'session#register', via:[:get]
  match '/logout', to: 'session#logout', via:[:get]

  resources :users
  resource :wechat, only: [:show, :create]
  resources :products

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount RuCaptcha::Engine => "/rucaptcha"
  # root "home#index"
  # root { to: "h5/lotteries", controller: 'h5/lotteries', action: 'index'}
  root "/", {controller: 'h5/lotteries', action: "index"}
end
