module Admins::RankingConfigsHelper

  def rcx_is_disabled
    if @ranking_config.ranking_config_items.present?
      return ''
    end
    return 'disabled'
  end

  def empty_award_is_checked
    if @ranking_config.ranking_config_items.present?
      return ''
    end
    return 'checked'
  end

  def rcx_is_checked data
    if data.present?
      return 'checked'
    end
    return ''
  end


  #所属排行类型-所属排行日期类别
  def ranking_type_helper ranking_type, date_type

    rt = '收益' if ranking_type.to_i == 1
    rt = '收益率' if ranking_type.to_i == 2
    dt = '本日排行' if date_type.to_i == 1
    dt = '本周排行' if date_type.to_i == 2
    dt = '本月排行' if date_type.to_i == 3
    dt = '本年排行' if date_type.to_i == 4
    v = "#{rt}-#{dt}"
    return v
  end

  #所属排行名次
  def ranking_helper ranking
    return ranking.to_i
  end


end