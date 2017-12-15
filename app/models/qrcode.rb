class Qrcode < ApplicationRecord
  validates :scene_id, uniqueness: true
  validates :user_name, presence: true
  has_many :qrcode_scan_records

  include Admins::QrcodeHelper



end
