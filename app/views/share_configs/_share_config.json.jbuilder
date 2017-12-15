json.extract! share_config, :id, :title, :desc, :img_url, :link_url, :user_id, :created_at, :updated_at
json.url share_config_url(share_config, format: :json)