FactoryBot.define do
  factory :notification do
    user_id 1
    destination_id 1
    from_user_id 1
    content "MyText"
    type 1
  end
end
