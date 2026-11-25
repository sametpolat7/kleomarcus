class Admin::DisciplinesController < Admin::BaseController
  before_action :set_discipline, only: %i[edit update destroy]

  def index
    @pagy, @disciplines = pagy(Discipline.ordered.includes(:trainers))
  end

  def new
    @discipline = Discipline.new
  end

  def create
    @discipline = Discipline.new(discipline_params)

    if @discipline.save
      redirect_to admin_disciplines_path, notice: "Branş oluşturuldu."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @discipline.update(discipline_params)
      redirect_to admin_disciplines_path, notice: "Branş güncellendi."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @discipline.destroy
      redirect_to admin_disciplines_path, notice: "Branş silindi.", status: :see_other
    else
      redirect_to admin_disciplines_path, alert: "Bu branş antrenörlere atanmış. Silmeden önce antrenörlerden kaldırın.", status: :see_other
    end
  end

  private

  def set_discipline
    @discipline = Discipline.find(params[:id])
  end

  def discipline_params
    params.expect(discipline: [ :name ])
  end
end
