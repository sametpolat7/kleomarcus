FactoryBot.define do
  factory :testimonial do
    author_name { Faker::Name.name }
    title { Faker::Lorem.sentence(word_count: 3) }
    content { Faker::Lorem.paragraph }
    rating { rand(1..5) }
  end
end
