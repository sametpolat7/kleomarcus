class Public::ClubsController < Public::BaseController
  def show; end

  def trainers
    @trainers = Trainer.ordered.with_attached_photo.includes(:disciplines)
  end

  def lessons
    @schedule_days  = Lesson.schedule_days
    @schedule_hours = Lesson.schedule_hours
    @schedule_kinds = Lesson.schedule_kinds
  end

  def gallery; end
end
