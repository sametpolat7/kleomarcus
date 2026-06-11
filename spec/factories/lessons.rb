FactoryBot.define do
  factory :lesson do
    name { Faker::Educator.course_name }
    day_of_week { Lesson.day_of_weeks.keys.sample }
    start_time { "09:00" }
    end_time { "10:00" }
    kind { Lesson.kinds.keys.sample }
    trainer
  end
end
