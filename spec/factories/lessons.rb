FactoryBot.define do
  factory :lesson do
    sequence(:name) { |n| "#{Faker::Educator.subject} #{n}" }
    day_of_week { :monday }
    start_time { "09:00" }
    end_time { "10:00" }

    trait :team do
      kind { :team }
    end
  end
end
