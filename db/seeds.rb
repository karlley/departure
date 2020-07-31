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
               introduction: "My name is Faker!",
               nationality: Faker::Address.country)
end

# Destination
10.times do |n|
  Destination.create!(name: Faker::Address.city,
                      description: "This Destination is Faker!",
                      country: Faker::Address.country,
                      user_id: 1)
end

# Relationship
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
