class Admin::EnrollmentsController < Admin::BaseController
  before_action :set_enrollment, only: %i[edit update destroy]

  def index
    @status = params[:status].presence_in(Enrollment.statuses.keys)
    @discipline = Discipline.find_by(slug: params[:discipline])

    scope = Enrollment.includes(:discipline).recent
    scope = scope.where(status: @status) if @status
    scope = scope.where(discipline: @discipline) if @discipline
    @pagy, @enrollments = pagy(scope)
  end

  def edit; end

  def update
    if @enrollment.update(enrollment_params)
      redirect_to admin_enrollments_path, notice: "Başvuru güncellendi."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @enrollment.destroy
    redirect_to admin_enrollments_path, notice: "Başvuru silindi.", status: :see_other
  end

  private

  def set_enrollment
    @enrollment = Enrollment.find(params[:id])
  end

  def enrollment_params
    params.expect(enrollment: [ :status ])
  end
end
