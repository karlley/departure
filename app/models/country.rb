class Country < ApplicationRecord
  has_many :destinations
  validates :country_name, presence: true
  validates :region, presence: true
end
