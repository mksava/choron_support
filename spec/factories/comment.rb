FactoryBot.define do
  factory :comment do
    sequence(:title) { |n| "title#{n}"}
    sequence(:body) { |n| "body#{n}"}
  end
end
