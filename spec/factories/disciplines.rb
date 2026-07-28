FactoryBot.define do
  factory :discipline do
    sequence(:name) { |n| "#{Faker::Sport.sport} #{n}" }
  end
end
