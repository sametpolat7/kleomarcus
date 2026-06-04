FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(specifier: 5..12, separators: %w[_]).downcase.gsub(/[^a-z0-9_]/, "_") }
    email_address { Faker::Internet.unique.email }
    password { "secret123" }
    password_confirmation { "secret123" }
    role { :staff }

    trait :admin do
      role { :admin }
    end

    trait :staff do
      role { :staff }
    end
  end
end
