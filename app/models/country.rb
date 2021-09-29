class Country < ApplicationRecord
  has_many :destinations
  has_ancestry
  validates :country_name, presence: true
  validate :region
  validate :ancestry
end
