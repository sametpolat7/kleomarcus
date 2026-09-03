class Public::ClubsController < Public::BaseController
  def show
    @trainers_count = Trainer.count
    @open_days = Lesson.opening_hours.size
  end
end
