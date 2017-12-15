ALIPAYCONFIG = YAML.load_file("config/myalipay.yml")[Rails.env].with_indifferent_access.freeze


