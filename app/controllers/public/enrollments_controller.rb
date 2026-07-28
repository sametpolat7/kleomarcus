class Public::EnrollmentsController < Public::BaseController
  rate_limit to: 5,
             within: 1.hour,
             only: :create,
             with: -> { redirect_to new_enrollment_path, alert: "Çok fazla başvuru gönderdiniz. Lütfen daha sonra tekrar deneyin." }

  def new
    @enrollment = Enrollment.new
  end

  def create
    @enrollment = Enrollment.new(enrollment_params)

    if @enrollment.save
      session[:enrollment_completed] = true
      redirect_to thanks_enrollment_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thanks
    redirect_to new_enrollment_path unless session.delete(:enrollment_completed)
  end

  private

  def enrollment_params
    params.expect(enrollment: [ :full_name, :phone, :email, :age, :message, :info_consent, :kvkk_consent ])
  end
end
