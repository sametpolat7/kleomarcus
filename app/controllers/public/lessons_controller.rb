class Public::LessonsController < Public::BaseController
  def index
    @schedule_days  = Lesson.schedule_days
    @schedule_hours = Lesson.schedule_hours
    @schedule_kinds = Lesson.schedule_kinds
  end
end
