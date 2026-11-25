FactoryBot.define do
  factory :membership_plan do
    sequence(:name) { |n| "#{Faker::Commerce.product_name} #{n}" }
    description { Faker::Lorem.sentence(word_count: 4) }
    monthly_price { Faker::Number.between(from: 1_000, to: 20_000) }
    sequence(:position)

    trait :featured do
      featured { true }
    end
  end
end
