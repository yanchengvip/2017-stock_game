# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( h5.js h5.css h5/cropper.min.js h5/main.js h5/cropper.min.css h5/main.css h5/bootstrap.min.js h5/bootstrap.min.css mustpay_wxpubsdk.js h5/script h5/alertgold)
