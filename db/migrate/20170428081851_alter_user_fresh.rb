class AlterUserFresh < ActiveRecord::Migration[5.0]
  def change
    User.where(is_fresh: false).update_all(is_fresh: true)
  end
end
