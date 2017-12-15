class Image < ApplicationRecord
  #mount_uploader :url, ImageUploader
  belongs_to :table, polymorphic: true
  validates :url, presence: true
end
