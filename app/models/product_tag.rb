class ProductTag < ApplicationRecord
  validates :name, uniqueness: true
  has_many :products
end