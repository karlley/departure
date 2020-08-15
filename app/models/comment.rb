class Comment < ApplicationRecord
  belongs_to :destination
  validates :user_id, presence: true
  validates :destination_id, presence: true
  validates :content, presence: true, length: { maximum: 50 }
end
