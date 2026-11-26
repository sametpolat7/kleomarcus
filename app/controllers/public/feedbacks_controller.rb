class Public::FeedbacksController < Public::BaseController
  rate_limit to: 5, within: 10.minutes, name: "burst", only: :create, by: :anonymized_client, with: :reject_as_too_frequent
  rate_limit to: 20, within: 1.day, name: "daily", only: :create, by: :anonymized_client, with: :reject_as_too_frequent

  def new
    @feedback = Feedback.new
  end

  def create
    return complete_submission if params[:website].present?

    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      complete_submission
    else
      render :new, status: :unprocessable_content
    end
  end

  def thanks
    redirect_to new_feedback_path unless session.delete(:feedback_submitted)
  end

  private

  def feedback_params
    params.expect(feedback: [ :topic, :message ])
  end

  def complete_submission
    session[:feedback_submitted] = true
    redirect_to thanks_feedback_path
  end

  def anonymized_client
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, request.remote_ip)
  end

  def reject_as_too_frequent
    @feedback = Feedback.new(feedback_params)
    @too_frequent = true
    render :new, status: :too_many_requests
  end
end
