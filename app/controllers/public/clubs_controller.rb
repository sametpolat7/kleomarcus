class Public::ClubsController < ApplicationController
  def show; end

  def trainers
    @trainers = Trainer.ordered.with_attached_photo.includes(:disciplines)
  end

  def lessons
    @schedule_days  = Lesson.schedule_days
    @schedule_hours = Lesson.schedule_hours
    @schedule       = Lesson.ordered.index_by { |lesson| [ lesson.day_of_week, lesson.start_time.strftime("%H:%M") ] }
  end

  def gallery; end
end
