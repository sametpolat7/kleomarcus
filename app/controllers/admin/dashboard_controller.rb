class Admin::DashboardController < Admin::BaseController
  helper Admin::LessonsHelper, Admin::EnrollmentsHelper

  def index
    @stats = {
      trainers: Trainer.count,
      lessons: Lesson.count,
      testimonials: Testimonial.count,
      users: User.count,
      enrollments: Enrollment.count
    }

    @recent_lessons = Lesson.ordered.includes(:trainer).limit(5)
    @recent_testimonials = Testimonial.ordered.limit(5)
    @recent_enrollments = Enrollment.includes(:discipline).received.recent.limit(5)
  end
end
