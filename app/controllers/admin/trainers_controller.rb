class Admin::TrainersController < Admin::BaseController
  before_action :set_trainer, only: %i[edit update destroy]

  def index
    @pagy, @trainers = pagy(Trainer.ordered.with_attached_photo.includes(:disciplines))
  end

  def new
    @trainer = Trainer.new
  end

  def create
    @trainer = Trainer.new(trainer_params)

    if @trainer.save
      redirect_to admin_trainers_path, notice: "Antrenör oluşturuldu."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @trainer.update(trainer_params)
      redirect_to admin_trainers_path, notice: "Antrenör güncellendi."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @trainer.destroy
    redirect_to admin_trainers_path, notice: "Antrenör silindi.", status: :see_other
  end

  private

  def set_trainer
    @trainer = Trainer.find(params[:id])
  end

  def trainer_params
    params.expect(trainer: [ :name, :title, :bio, :position, :photo, discipline_ids: [] ])
  end
end
