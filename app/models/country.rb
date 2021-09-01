class Country < ApplicationRecord
  has_many :destinations
  has_ancestry
  validates :country_name, presence: true
  validates :region, presence: true
end
