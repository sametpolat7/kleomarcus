class Public::HomeController < Public::BaseController
  def index
    @testimonials = Testimonial.all
  end
end
