FactoryBot.define do
  factory :trainer do
    name { Faker::Name.name }
    title { Faker::Job.title }
  end
end
