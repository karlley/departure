class User < ApplicationRecord
  has_many :destinations, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :favorites, dependent: :destroy
  # destinations テーブルからfavorite 済みのデータを取得
  has_many :favorite_destinations, through: :favorites, source: :destination
  has_many :notifications, dependent: :destroy
  attr_accessor :remember_token
  before_save :downcase_email
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュを返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションの為にremember_token を保存
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # ログイン状態でremember_token, remember_digest が一致したらtrue を返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン破棄
  def forget
    update_attribute(:remember_digest, nil)
  end

  # ユーザーをフォローする
  def follow(other_user)
    following << other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしていたらtrue を返す
  def following?(other_user)
    following.include?(other_user)
  end

  # 現在のユーザーがフォローされていたらtrue を返す
  def followed_by?(other_user)
    followers.include?(other_user)
  end

  # ユーザーのステータスフィードを返す
  def feed
    # フォロー中のuser_id を取得
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    # フォロー中のユーザ、自分の投稿を検索
    Destination.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
  end

  # お気に入り登録
  def favorite(destination)
    Favorite.create!(user_id: id, destination_id: destination.id)
  end

  # お気に入り解除
  def unfavorite(destination)
    Favorite.find_by(user_id: id, destination_id: destination.id).destroy
  end

  # 現在のユーザーがお気に入り登録済みの場合にtrue を返す
  def favorite?(destination)
    !Favorite.find_by(user_id: id, destination_id: destination.id).nil?
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
