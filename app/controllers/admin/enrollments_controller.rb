class Admin::EnrollmentsController < Admin::BaseController
  before_action :set_enrollment, only: %i[edit update destroy]

  def index
    @status = params[:status].presence_in(Enrollment.statuses.keys)

    scope = Enrollment.recent
    scope = scope.where(status: @status) if @status
    @pagy, @enrollments = pagy(scope)
  end

  def edit; end

  def update
    if @enrollment.update(enrollment_params)
      redirect_to admin_enrollments_path, notice: "Başvuru güncellendi."
    else
      render :edit, status: :unprocessable_content
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
