class Admin::LessonsController < Admin::BaseController
  before_action :set_lesson, only: %i[edit update destroy]

  def index
    @schedule = Lesson.schedule
    @schedule_days = Lesson.schedule_days
    @schedule_hours = Lesson.schedule_hours
  end

  def new
    @lesson = Lesson.new(new_lesson_defaults)
  end

  def create
    @lesson = Lesson.new(lesson_params)

    if @lesson.save
      redirect_to admin_lessons_path, notice: "Ders oluşturuldu."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @lesson.update(lesson_params)
      redirect_to admin_lessons_path, notice: "Ders güncellendi."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @lesson.destroy
    redirect_to admin_lessons_path, notice: "Ders silindi.", status: :see_other
  end

  private

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end

  def lesson_params
    params.expect(lesson: [ :name, :day_of_week, :start_time, :end_time, :kind, :trainer_id ])
  end

  def new_lesson_defaults
    params.permit(:day_of_week, :start_time, :end_time).to_h.compact_blank
  end
end
