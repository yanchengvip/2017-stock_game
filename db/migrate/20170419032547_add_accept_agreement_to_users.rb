class AddAcceptAgreementToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :accept_agreement, :boolean, default: false, comment: '是否接受协议.'
  end
end
