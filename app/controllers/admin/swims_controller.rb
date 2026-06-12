class Admin::SwimsController < Admin::BaseController
  before_action :set_swim, only: %i[edit update destroy]

  def index
    @status = params[:status].presence_in(Swim.statuses.keys)
    scope = Swim.applications.recent
    scope = scope.where(status: @status) if @status
    @pagy, @swims = pagy(scope)
  end

  def edit; end

  def update
    if @swim.update(swim_params)
      redirect_to admin_swims_path, notice: "Başvuru güncellendi."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @swim.destroy
    redirect_to admin_swims_path, notice: "Başvuru silindi.", status: :see_other
  end

  private

  def set_swim
    @swim = Swim.find(params[:id])
  end

  def swim_params
    params.expect(swim: [ :status ])
  end
end
