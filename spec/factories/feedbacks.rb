FactoryBot.define do
  factory :feedback do
    topic { Feedback.topics.keys.sample }
    message { Faker::Lorem.paragraph(sentence_count: 2) }
  end
end
