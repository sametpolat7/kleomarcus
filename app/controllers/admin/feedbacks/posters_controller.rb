class Admin::Feedbacks::PostersController < Admin::BaseController
  layout "print"

  def show
    @feedback_url = URI.join(Rails.configuration.x.club.url, new_feedback_path).to_s
  end
end
