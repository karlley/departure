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
  validates :spot, length: { maximum: 50 }
  validates :address, length: { maximum: 50 }
  validate :picture_size

  # geocoder で経度, 緯度を取得する
  geocoded_by :address_keyword
  after_validation :geocode

  # geocoder で使用する文字列を生成
  def address_keyword
    [name, country, spot].compact.join(', ')
  end

  # geocode 後の座標からaddress を追加する
  def add_address
    if latitude.present?
      self.address = Geocoder.search([latitude, longitude]).first.address
      save
    end
  end

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
