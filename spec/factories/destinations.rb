FactoryBot.define do
  factory :destination do
    name { Faker::Address.city }
    country { Faker::Address.country }
    sequence(:description) { |n| "This is Faker Destinaton No.#{n}!" }
    spot { Faker::Address.street_name }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    # address { Geocoder.search([latitude, longitude]) }
    address { Faker::Address.full_address }
    expense { Faker::Number.between(from: 1, to: 100) * 10000 }
    season { Faker::Number.between(from: 1, to: 12) }
    experience { "Your Experience!" }
    airline { "Select Airline Company!" }
    food { Faker::Food.dish }
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

  trait :picture do
    picture { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec/fixtures/test_destination_1.jpg')) }
  end
end
