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
  email = "sample-#{n+1}@example.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               introduction: "My name is Faker No.#{n+1}!",
               nationality: Faker::Address.country)
end

# Destination
10.times do |n|
  Destination.create!(name: Faker::Address.city,
                      description: "This is Faker Destination No.#{n+1}!",
                      country: Faker::Address.country,
                      spot: Faker::Address.street_name,
                      latitude: Faker::Address.latitude,
                      longitude: Faker::Address.longitude,
                      # address: Geocoder.search([:latitude, :longitude]).first.address,
                      address: Faker::Address.full_address,
                      expense: Faker::Number.between(from:1, to: 100) * 10000,
                      season: Faker::Number.between(from:1, to: 12),
                      experience: "Your Experience!",
                      airline: "Select Airline Company!",
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
