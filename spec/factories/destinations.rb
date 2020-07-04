FactoryBot.define do
  factory :destination do
    name { Faker::Address.city }
    country { "Japan" }
    description { "This is Faker place!" }
    association :user
  end
end
