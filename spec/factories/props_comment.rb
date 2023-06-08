FactoryBot.define do
  factory :props_comment do
    sequence(:title) { |n| "title#{n}"}
    sequence(:body) { |n| "body#{n}"}
  end
end
