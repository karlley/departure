class Destination < ApplicationRecord
  belongs_to :user
  default_scope { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :country, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 140 }, allow_nil: true
end
