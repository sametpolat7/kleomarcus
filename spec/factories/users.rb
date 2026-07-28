FactoryBot.define do
  factory :user do
    sequence(:username) do |n|
      "#{Faker::Internet.username(specifier: 4..8, separators: %w[_]).downcase.gsub(/[^a-z0-9_]/, "_")}_#{n}"
    end
    email_address { Faker::Internet.unique.email }
    password { AdminAuth::PASSWORD }

    trait :admin do
      role { :admin }
    end

    trait :staff do
      role { :staff }
    end

    trait :athlete do
      role { :athlete }
    end
  end
end
