FactoryBot.define do
  factory :press_item do
    publisher { Faker::Company.name }
    publisher_kind { :local_press }
    sequence(:headline) { |n| "#{Faker::Lorem.sentence(word_count: 5).chomp(".")} #{n}" }
    sequence(:url) { |n| "https://example.com/haber-#{n}" }
    published_on { Date.new(2025, 11, 16) }

    trait :visible do
      published { true }
      sequence(:archive_url) { |n| "https://web.archive.org/web/20251116/https://example.com/haber-#{n}" }
    end

    trait :unarchived do
      published { true }
      archive_url { nil }
    end
  end
end
