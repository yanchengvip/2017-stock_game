# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join("config/app.yml")
  namespace Rails.env

  #新增永久图文素材
  def self.init_image_media(key, file_path)
    res = Wechat.api.material_add( "image", file_path)
    Setting[key] = res["media_id"]
  end
end
