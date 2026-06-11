FactoryBot.define do
  factory :trainer do
    name { Faker::Name.name }
    title { Faker::Job.title }
    bio { Faker::Lorem.paragraph }
  end
end
