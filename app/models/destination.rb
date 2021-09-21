class Destination < ApplicationRecord
  belongs_to :user
  belongs_to :country
  # optionnal: ture でairline 未選択も許可する
  belongs_to :airline, optional: true
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy
  default_scope { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :region_id, presence: true
  validates :country_id, presence: true
  # 費用をenum で管理する
  enum expense: {
    till_50000: 1,
    till_100000: 2,
    till_200000: 3,
    till_300000: 4,
    till_500000: 5,
    till_700000: 6,
    till_1000000: 7,
    over_1000000: 8,
  }
  # enum 定義以外の値を許可しない
  validates :expense, inclusion: { in: Destination.expenses.keys }
  validates :season, presence: true
  validate :airline_id
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
    # 国名が選択されている場合は国番号から国名を検索
    if country_id.present?
      # Country の中からself のcountry_id をもとにcountry_name を探してcountry_name に代入
      country_name = Country.find_by(id: country_id).country_name
      [name, country_name, spot].compact.join(', ')
    end
  end

  # geocode 後の座標からaddress を追加する
  def add_address
    if latitude && longitude.present?
      self.address = Geocoder.search([latitude, longitude]).first.address
      save
    end
  end

  # 座標が更新された場合のみgeocode してaddress を更新する
  def update_address
    # if saved_change_to_latitude? || saved_change_to_longitude?
    if will_save_change_to_attribute?("latitude") || will_save_change_to_attribute?("longitude")
      self.address = Geocoder.search([latitude, longitude]).first.address
      update!(address: address)
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
