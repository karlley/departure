class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :destination
  validates :user_id, presence: true
  validates :destination_id, presence: true
end
