FactoryBot.define do
  factory :user, aliases: [:follower, :followed] do
    name { Faker::Name.name }
    sequence(:email) { |n| "example#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    sequence(:introduction) { |n| "Hello! My name is Faker No.#{n}!" }
    nationality { Faker::Address.country }

    trait :admin do
      admin { true }
    end
  end
end
