# ActionStore Config
ActionStore.configure do
end

WECHATCONFiG = YAML.load_file("config/wechat.yml")[Rails.env].with_indifferent_access.freeze
SYSTEMCONFIG = YAML.load_file("config/system_config.yml")[Rails.env].with_indifferent_access.freeze
DATABSECONFIG = YAML.load_file("config/database.yml").with_indifferent_access.freeze

MUSTAPAYCONFIG = YAML.load_file("config/mustpay.yml")[Rails.env].with_indifferent_access.freeze
