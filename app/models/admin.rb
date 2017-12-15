class Admin < ApplicationRecord
  validates :phone, uniqueness: true
  validates :nickname, uniqueness: true
  before_create :encrypt_password
  before_update :check_password_change

  #用户登录
  def self.login(phone, password)
    user = Admin.where(phone: phone).first
    if user
      if Digest::SHA1.hexdigest(password+user.salt) == user.encrypted_password
        return user
      else
        return nil
      end
    else
      return nil
    end
  end


  #生成用户密码
  def encrypt_password
    if encrypted_password
      self.salt = (('a'..'z').to_a+(0..9).to_a+('A'..'Z').to_a).sample(32).join("")
      self.encrypted_password = Digest::SHA1.hexdigest(self.encrypted_password+self.salt)
    end
  end



  #更改用户密码
  def check_password_change
    if self.encrypted_password_change
      self.salt = (('a'..'z').to_a+(0..9).to_a+('A'..'Z').to_a).sample(32).join("") if self.salt.nil?
      self.encrypted_password = Digest::SHA1.hexdigest(self.encrypted_password+self.salt)
    end
  end


  #后台修改用户密码验证
  def valid_current_password password
    if Digest::SHA1.hexdigest(password+self.salt) == self.encrypted_password
      return true
    else
      return false
    end

  end

end
