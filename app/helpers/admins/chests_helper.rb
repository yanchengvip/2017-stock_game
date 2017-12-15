module Admins::ChestsHelper

  def status_str chest
    case chest.status
    when 0
      '停用'
    when 1
      '启用'
    end
  end
end
