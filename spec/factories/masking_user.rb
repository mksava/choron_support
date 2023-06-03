FactoryBot.define do
  factory :masking_user do
    sequence(:name) { |n| "name#{n}"}
    is_super_man { [true, false].sample }
    weight { 70 + rand(30) }
    height { 170.4 + rand(30) }
    birth_date { Date.new(1990 + rand(10), 1 + rand(5), 1 + rand(20)) }
  end
end
