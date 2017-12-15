# config valid only for current version of Capistrano
lock "3.7.1"
set :rails_env, :production
set :application, "stock_game"
set :repo_url, "github.com"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/data/www/stock_game"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :linked_dirs, %w{ log tmp/pids tmp/cache tmp/sockets vendor/bundle public/uploads }
set :linked_files, %w{config/database.yml config/secrets.yml config/system_config.yml config/environments/production.rb config/wechat.yml config/myalipay.yml config/mustpay.yml}
# set :linked_files, %w{config/database.yml config/secrets.yml }
# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 100
after 'deploy:publishing', 'deploy:restart'



namespace :deploy do
  task :restart do
    invoke 'unicorn:legacy_restart'
    # invoke 'sidekiq:restart'
  end
end
