FactoryBot.define do
  factory :master_plan, class: Master::Plan do
    sequence(:name) { |n| "name#{n}"}
  end
end
