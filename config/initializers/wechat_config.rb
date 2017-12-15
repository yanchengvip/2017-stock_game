$cache ||= Dalli::Client.new(SYSTEMCONFIG['cache_servers'])
$redis ||= Redis.new(:url => SYSTEMCONFIG["redis"]["url"])
