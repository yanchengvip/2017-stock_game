require_relative 'boot'
require 'csv'
require 'rails/all'
require "rexml/document"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StockGame
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    SYSTEMCONFIG = YAML.load_file("config/system_config.yml")
    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]
    config.eager_load_paths += %W(#{Rails.root}/lib)
    config.active_job.queue_adapter = :sidekiq

  end
end
