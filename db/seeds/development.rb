# Country CSV import
# Destination のseed が作成できないので先にCountry, Airline を作成
require "csv"

CSV.foreach("country.csv", headers: true) do |row|
  Country.create!(
    country_name: row["国・地域名"],
    region: row["場所"]
  )
end

# Airline CSV import
CSV.foreach("airline.csv", headers: true) do |row|
  Airline.create!(
    airline_name: row["航空会社"],
    country_id: row["国番号"],
    alliance: row["アライアンス"],
    alliance_type: row["アライアンス種別"]
  )
end

# Admin User
User.create!(name: "Example User",
             email: "sample@example.com",
             password: "password",
             password_confirmation: "password",
             introduction: "My name is Example User!",
             nationality: "Japan",
             admin: true)

# User
99.times do |n|
  name = Faker::Name.name
  email = "sample-#{n + 1}@example.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               introduction: "My name is Faker No.#{n + 1}!",
               nationality: Faker::Address.country)
end

# Destination
10.times do |n|
  Destination.create!(name: Faker::Address.city,
                      description: "This is Faker Destination No.#{n + 1}!",
                      # seed で作成したCountry オブジェクトの中からランダムに国を選択
                      country_id: Country.find(Faker::Number.between(from: 1, to: 249)).id,
                      spot: Faker::Address.street_name,
                      latitude: Faker::Address.latitude,
                      longitude: Faker::Address.longitude,
                      # address: Geocoder.search([:latitude, :longitude]).first.address,
                      address: Faker::Address.full_address,
                      # :expense のenum 表示に合わせて1-8 の数字を生成,
                      expense: Faker::Number.between(from: 1, to: 8),
                      season: Faker::Number.between(from: 1, to: 12),
                      experience: "Your Experience!",
                      # seed で作成したAirline オブジェクトの中からランダムに国を選択
                      airline_id: Airline.find(Faker::Number.between(from: 1, to: 90)).id,
                      food: Faker::Food.dish,
                      user_id: 1)
end

# Relationship
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
