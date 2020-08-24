FactoryBot.define do
  factory :notification do
    user_id 1
    destination_id 1
    from_user_id 2
    content ""
    type 1
    association :user
  end
end
