FactoryBot.define do
  factory :enrollment do
    full_name { Faker::Name.name }
    phone { "05#{Faker::Number.number(digits: 9)}" }
    age { Faker::Number.between(from: 3, to: 75) }
    info_consent { true }
    kvkk_consent { true }
  end
end
