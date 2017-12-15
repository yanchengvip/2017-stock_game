class Cqssc < ApplicationRecord
  validates :expect, uniqueness: true
  def self.update_data_from_apiplus
    url = "#{SYSTEMCONFIG[:opencai_api]}newly.do?token=97bee0d1cb11a03a&code=cqssc&format=json&rows=20"
    res = JSON.parse(Faraday.get(url).body)
    res["data"].each do |r|
      begin
        Cqssc.create(r.slice("expect", "opencode", "opentime", "opentimestamp"))
      rescue Exception => e
      end
    end
  end

  def self.lottery_opencode(time, number = 0)
    if number == 0
      Cqssc.where("opentime > ?", time.strftime("%Y-%m-%d %H:%M:%S")).order("opentime desc").limit(1).first
    else
      Cqssc.where("opentime <= ?", time.strftime("%Y-%m-%d %H:%M:%S")).order("opentime desc").limit(number).last
    end
  end
end
