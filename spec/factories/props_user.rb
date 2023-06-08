FactoryBot.define do
  factory :props_user do
    sequence(:name) { |n| "name#{n}"}
    sequence(:email) { |n| "email#{n}@example.com"}
  end
end
