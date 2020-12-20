FactoryBot.define do
  factory :destination do
    name { Faker::Address.city }
    # :country のCSV 用に1-249 の数字を生成
    country { Faker::Number.between(from: 1, to: 249) }
    sequence(:description) { |n| "This is Faker Destinaton No.#{n}!" }
    spot { Faker::Address.street_name }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    # address { Geocoder.search([latitude, longitude]) }
    address { Faker::Address.full_address }
    # :expense のenum 用に1-8 の数字を生成
    expense { Faker::Number.between(from: 1, to: 8) }
    season { Faker::Number.between(from: 1, to: 12) }
    experience { "Your Experience!" }
    # :airline のCSV 用に1-91 の数字を生成
    airline { Faker::Number.between(from: 1, to: 91) }
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
