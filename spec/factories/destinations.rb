FactoryBot.define do
  factory :destination do
    name { Faker::Address.city }
    country { "Japan" }
    description { "This is Faker place!" }
    association :user
    created_at { Time.current }
  end

  trait :yesterday do
    created_at { 1.day.ago }
  end

  trait :one_week_ago do
    created_at { 1.week.ago }
  end

  trait :one_month_ago do
    created_at { 1.month.ago }
  end
end
