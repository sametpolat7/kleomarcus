class Public::EnrollmentsController < Public::BaseController
  before_action :set_discipline

  def new
    @enrollment = @discipline.enrollments.build
  end

  def create
    @enrollment = @discipline.enrollments.build(enrollment_params)

    if @enrollment.save
      EnrollmentMailer.new_application(@enrollment).deliver_later
      session[:enrollment_completed] = true
      redirect_to enrollment_thanks_path(@discipline)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thanks
    redirect_to new_enrollment_path(@discipline) unless session.delete(:enrollment_completed)
  end

  private

  def set_discipline
    @discipline = Discipline.find_by!(slug: params[:discipline])
  end

  def enrollment_params
    params.expect(enrollment: [ :full_name, :phone, :email, :age, :level, :message, :info_consent, :kvkk_consent ])
  end
end
