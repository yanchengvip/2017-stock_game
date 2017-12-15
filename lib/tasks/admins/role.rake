# rails admin_role:role
namespace :admin_role do

  task role: :environment do
    user_to_admin
  end

  def user_to_admin
    user_ids = Role.select(:user_id).distinct(:user_id).pluck(:user_id)
    Admin.skip_callback(:create, :before, :encrypt_password)
    User.where(id: user_ids).each do |u|
      if u.nickname.blank?
        nickname = 'admin' + u.id.to_s
      else
        nickname = u.nickname
      end
      if u.phone.blank?
        phone = u.id
      else
        phone = u.phone
      end
      Admin.create(nickname: nickname, phone: phone,
                   encrypted_password: u.encrypted_password, salt: u.salt, role: 2, status: 1)
    end
    Admin.set_callback(:create, :before, :encrypt_password)
  end
end
