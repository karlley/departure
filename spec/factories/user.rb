FactoryBot.define do
  factory :user, aliases: [:follower, :followed] do
    name { Faker::Name.name }
    sequence(:email) { |n| "example#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    introduction { "Hello! My name is Faker!" }
    nationality { "Japan" }

    trait :admin do
      admin { true }
    end
  end
end
