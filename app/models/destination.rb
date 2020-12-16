class Destination < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy
  default_scope { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :country, presence: true, length: { maximum: 100 }
  validates :expense, presence: true
  validates :season, presence: true
  validate :airline
  validates :description, length: { maximum: 140 }, allow_nil: true
  validates :spot, length: { maximum: 100 }
  validates :address, length: { maximum: 100 }
  validates :experience, length: { maximum: 50 }
  validates :food, length: { maximum: 50 }
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
    if latitude && longitude.present?
      self.address = Geocoder.search([latitude, longitude]).first.address
      save
    end
  end

  # 座標が更新されたら再度geocode してaddress を更新する
  def update_address
    if saved_change_to_latitude? || saved_change_to_longitude?
      self.address = Geocoder.search([latitude, longitude]).first.address
      save
    end
  end

  # 行き先に付属するコメントのフィードを作成
  def feed_comment(destination_id)
    Comment.where("destination_id = ?", destination_id)
  end

  # 費用をenum で管理する
  enum expense: {
    "費用を選択してください": 0,
    "￥10,000 ~ ￥50,000": 1,
    "￥50,000 ~ ￥100,000": 2,
    "￥100,000 ~ ￥200,000": 3,
    "￥200,000 ~ ￥300,000": 4,
    "￥300,000 ~ ￥500,000": 5,
    "￥500,000 ~ ￥700,000": 6,
    "￥700,000 ~ ￥1000,000": 7,
    "￥1000,000 ~": 8,
  }

  private

  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, ":Image larger than 5MB cannot be uploaded.")
    end
  end
end
