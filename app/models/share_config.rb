#share_type =  0:初始,1:微信内容分享,2:公告管理
#status = 0:禁用，1:启用
class ShareConfig < ApplicationRecord
  after_save :clear_cache
  after_destroy :clear_cache
  def self.random_config(current_user)
    configs = $cache.fetch("admin_share_configs", 10 * 60){
      ShareConfig.select(:title, :desc, :id).where(share_type: 1,status: 1).to_a.as_json
    }
    if configs.blank?
      res = {
        "title" => "快来帮帮我！我要中iPhone！",
        "desc" => "{用户昵称}邀您组团【0元夺宝】一起中iPhone和克拉钻！",
        "id" => 0
      }
    else
      res = configs[rand(configs.size)]
    end
    res["title"] = res["title"].gsub("{用户昵称}", current_user.nickname)
    res["desc"] = res["desc"].gsub("{用户昵称}", current_user.nickname)
    return res
  end


  #首页公告
  def self.show_notice
    notice = $cache.fetch("admin_share_configs_notice", 60 * 60){
      ShareConfig.select(:id,:title, :desc).where(share_type: 2,status: 1).order('created_at desc').first.as_json
    }
  end

  private
  def clear_cache
    $cache.delete("admin_share_configs")
    $cache.delete("admin_share_configs_notice")
  end
end
