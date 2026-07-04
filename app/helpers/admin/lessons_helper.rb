module Admin::LessonsHelper
  LESSON_KIND_VARIANTS = {
    "solo" => :neutral,
    "team" => :primary
  }.freeze

  def lesson_kind_label(lesson)
    badge(Lesson.enum_label(:kind, lesson.kind), variant: LESSON_KIND_VARIANTS[lesson.kind])
  end
end
