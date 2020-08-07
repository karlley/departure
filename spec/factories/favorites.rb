FactoryBot.define do
  factory :favorite do
    association :destination
    association :user
  end
end
