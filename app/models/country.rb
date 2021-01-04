class Country < ApplicationRecord
  validates :country_name, presence: true
  validates :region, presence: true
end
