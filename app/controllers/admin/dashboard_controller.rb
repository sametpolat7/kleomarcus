class Admin::DashboardController < Admin::BaseController
  def index
    @stats = {
      trainers: Trainer.count,
      lessons: Lesson.count,
      testimonials: Testimonial.count,
      users: User.count
    }
    @recent_lessons = Lesson.ordered.includes(:trainer).limit(5)
    @recent_testimonials = Testimonial.ordered.limit(5)
  end
end
