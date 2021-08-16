class Airline < ApplicationRecord
  has_many :destinations
  validates :airline_name, presence: true
  validates :country_id, presence: true
  validates :alliance, presence: true
  validates :alliance_type, presence: true
end
