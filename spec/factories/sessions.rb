FactoryBot.define do
  factory :session do
    user

    trait :expired do
      expires_at { 1.minute.ago }
    end
  end
end
