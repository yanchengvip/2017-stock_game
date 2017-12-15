#status: -1: 删除，0:正常
class Address < ApplicationRecord
  belongs_to :user
  validates :user_name, presence: true
  validates :phone, presence: true
  validates :postcode, presence: true
  validates :address, presence: true
  validates :user_id, presence: true
  scope :default, -> {where(is_default: true)}
  after_save :set_is_default
  private

  def set_is_default
    if self.is_default
      addresses = Address.where(status: 0,user_id: self.user_id,is_default: true)
      addresses.each do |addr|
        if addr.id != self.id
          addr.update_attributes(is_default: false)
        end
      end
    end

    #确保始终有默认地址
    # addresses = Address.where(status: 0,user_id: self.user_id,is_default: true)
    # if addresses.empty?
    #   address = Address.where(status: 0,user_id: self.user_id,is_default: false).where.not(id: self.id).first
    #   if address.present?
    #     address.update_attributes(is_default: true)
    #   end
    #
    # end

  end

end
