class Destination < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy
  default_scope { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :country, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 140 }, allow_nil: true
  validate :picture_size

  # 行き先に付属するコメントのフィードを作成
  def feed_comment(destination_id)
    Comment.where("destination_id = ?", destination_id)
  end

  private

  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, ":Image larger than 5MB cannot be uploaded.")
    end
  end
end
