FactoryBot.define do
  factory :comment do
    user_id { 1 }
    content { "This is a comment!" }
    association :destination
  end
end
