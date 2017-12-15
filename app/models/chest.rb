class Chest < ApplicationRecord

  after_save :clear_cache_datas

  private
  def clear_cache_datas
    $cache.set('chest_container_now', nil)
    $cache.set('chest_odds_container_now', nil)
  end
end
