FactoryBot.define do
  factory :favorite do
    association :destination
    # association :user だとuser が重複して生成されるので生成したdestination のuser を指定
    user { destination.user }
  end
end
