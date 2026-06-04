class Admin::TestimonialsController < Admin::BaseController
  before_action :set_testimonial, only: %i[edit update destroy]

  def index
    @pagy, @testimonials = pagy(Testimonial.ordered)
  end

  def new
    @testimonial = Testimonial.new
  end

  def create
    @testimonial = Testimonial.new(testimonial_params)

    if @testimonial.save
      redirect_to admin_testimonials_path, notice: "Yorum oluşturuldu."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @testimonial.update(testimonial_params)
      redirect_to admin_testimonials_path, notice: "Yorum güncellendi."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @testimonial.destroy
    redirect_to admin_testimonials_path, notice: "Yorum silindi.", status: :see_other
  end

  private

  def set_testimonial
    @testimonial = Testimonial.find(params[:id])
  end

  def testimonial_params
    params.expect(testimonial: [ :author_name, :title, :content, :rating ])
  end
end
