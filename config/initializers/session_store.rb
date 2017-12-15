# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_stock_game_session1'
Rails.application.config.session_store :mem_cache_store, :memcache_server => SYSTEMCONFIG['cache_servers'], :key => '_stock_game_session3', :expire_after => 1.hours, domain: SYSTEMCONFIG[:domain]
