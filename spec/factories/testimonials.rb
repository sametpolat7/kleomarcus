FactoryBot.define do
  factory :testimonial do
    author_name { Faker::Name.name }
    content { Faker::Lorem.paragraph }
  end
end
