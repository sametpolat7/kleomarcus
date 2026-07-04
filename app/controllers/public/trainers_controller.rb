class Public::TrainersController < Public::BaseController
  def index
    @trainers = Trainer.ordered.with_attached_photo.includes(:disciplines)
  end
end
