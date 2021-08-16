FactoryBot.define do
  factory :destination do
    name { Faker::Address.city }
    # seed で作成したCountry オブジェクトの中からランダムに国を選択
    country_id { Country.find(Faker::Number.between(from: 1, to: 249)).id }
    sequence(:description) { |n| "Destinaton No.#{n}!" }
    spot { Faker::Address.street_name }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    address { Faker::Address.full_address }
    # :expense のenum 用に1-8 の数字を生成
    expense { Faker::Number.between(from: 1, to: 8) }
    season { Faker::Number.between(from: 1, to: 12) }
    experience { "Your Experience!" }
    # seed で作成したAirline オブジェクトの中からランダムに国を選択
    airline_id { Airline.find(Faker::Number.between(from: 1, to: 90)).id }
    food { Faker::Food.dish }
    association :user
    created_at { Time.current }

    # インスタンス作成後にaddress を取得
    # 動作が安定しないので未使用
    # after(:build) do |destination|
    #   destination.add_address
    # end
  end

  trait :yesterday do
    name { "Yesterday" }
    created_at { 1.day.ago }
  end

  trait :one_week_ago do
    name { "One_Week_Ago" }
    created_at { 1.week.ago }
  end

  trait :one_month_ago do
    name { "One_Month_Ago" }
    created_at { 1.month.ago }
  end

  trait :picture do
    picture { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec/fixtures/test_destination_1.jpg')) }
  end

  trait :airline_unselected do
    name { "Airline_Unselected" }
    airline_id { nil }
  end

  trait :region_asia do
    name { "Region_Asia" }
    # 日本
    country_id { 153 }
  end

  trait :region_america do
    name { "Region_America" }
    # アメリカ
    country_id { 5 }
  end

  trait :region_europe do
    name { "Region_Europe" }
    # イギリス
    country_id { 19 }
  end

  trait :experience_activity do
    name { "Experience_Activity" }
    experience { "アクティビティ" }
  end

  trait :experience_history do
    name { "Experience_History" }
    experience { "歴史" }
  end

  trait :experience_solo_travel do
    name { "Experience_Solo_Travel" }
    experience { "一人旅" }
  end

  trait :alliance_star_alliance do
    name { "Alliance_Star_Alliance" }
    # 全日空
    airline_id { 2 }
  end

  trait :alliance_one_world do
    name { "Alliance_One_World" }
    # 日本航空
    airline_id { 1 }
  end

  trait :alliance_sky_team do
    name { "Alliance_Sky_Team" }
    # 中国東方航空
    airline_id { 11 }
  end
end
