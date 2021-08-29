# Faker を日本語に設定
Faker::Config.locale = :ja

# CSV import
# Destination のseed が作成できないので先にCountry, Airline を作成

# Country
require "csv"

CSV.foreach("country.csv", headers: true) do |row|
  Country.create!(
    country_name: row["国・地域名"],
    region: row["場所"]
  )
end

# Airline
CSV.foreach("airline.csv", headers: true) do |row|
  Airline.create!(
    airline_name: row["航空会社"],
    country_id: row["国番号"],
    alliance: row["アライアンス"],
    alliance_type: row["アライアンス種別"]
  )
end

# User

# Admin
User.create!(name: "管理人",
             email: "admin@example.com",
             password: "password",
             password_confirmation: "password",
             introduction: "管理人です。",
             nationality: "日本",
             admin: true)

# General User
3.times do |n|
  name = Faker::Name.name
  email = "general-#{n + 1}@example.com"
  password = "password"
  introduction = "#{n + 1}番目の一般ユーザーです！"
  nationality = "日本"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               introduction: introduction,
               nationality: nationality)
end

# Destination

10.times do |n|
  picture = File.open("#{Rails.root}/app/assets/images/sample/sample_#{Faker::Number.between(from: 1, to: 10)}.jpg")
  # 旅先名のリスト
  name = "サンプル #{n + 1}の旅先"
  description = "これは#{n + 1}番目の旅先です！"
  # :expense のenum 表示に合わせて1-8 の数字を生成,
  expense = Faker::Number.between(from: 1, to: 8)
  season = Faker::Number.between(from: 1, to: 12)
  # seed で作成したCountry オブジェクトの中からランダムに国を選択
  country_id = Country.find(Faker::Number.between(from: 1, to: 249)).id
  spot = Faker::Address.street_name
  latitude = Faker::Address.latitude
  longitude = Faker::Address.longitude
  address = Faker::Address.full_address
  # :expense のenum 表示に合わせて1-8 の数字を生成,
  expense = Faker::Number.between(from: 1, to: 8)
  season = Faker::Number.between(from: 1, to: 12)
  # 体験の中からランダムに選択
  experience_list = ["アクティビティ", "歴史", "一人旅"]
  experience = experience_list[Faker::Number.between(from: 0, to: 2)]
  # seed で作成したAirline オブジェクトの中からランダムに航空会社を選択
  airline_id = Airline.find(Faker::Number.between(from: 1, to: 90)).id
  food = Faker::Food.dish
  # 管理人は含まない
  user_id = Faker::Number.between(from: 2, to: 4)

  Destination.create!(picture: picture,
                      name: name,
                      description: description,
                      country_id: country_id,
                      spot: spot,
                      latitude: latitude,
                      longitude: longitude,
                      address: address,
                      expense: expense,
                      season: season,
                      experience: experience,
                      airline_id: airline_id,
                      food: food,
                      user_id: user_id)
end

# Relationship
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
