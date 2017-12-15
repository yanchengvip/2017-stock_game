
wechat:
  rails generate wechat:install
  rails g wechat:session
  rake db:migrate
  rails g wechat:redis_store

simple_form:
  <!-- rails generate simple_form:install -->
  rails generate simple_form:install --bootstrap

rucaptcha:
  Create config/initializers/rucaptcha.rb
  RuCaptcha.configure do
    # Number of chars, default: 4
    self.len = 4
    # Image font size, default: 45
    self.font_size = 45
    # Cache generated images in file store, this is config files limit, default: 100
    # set 0 to disable file cache.
    self.cache_limit = 100
    # Custom captcha code expire time if you need, default: 2 minutes
    # self.expires_in = 120
    # Color style, default: :colorful, allows: [:colorful, :black_white]
    # self.style = :colorful
    # [Requirement]
    # Store Captcha code where, this config more like Rails config.cache_store
    # default: Rails application config.cache_store
    # But RuCaptcha requirements cache_store not in [:null_store, :memory_store, :file_store]
    self.cache_store = :mem_cache_store
  end

cancancan:
  rails g cancan:ability

twitter-bootstrap-rails:
  rails generate bootstrap:install less
  rails generate bootstrap:install static
  rails g bootstrap:layout admin

capistrano
  bundle exec cap install
