class Courier < ApplicationRecord
  belongs_to :table, polymorphic: true
end
