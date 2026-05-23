class Public::HomeController < Public::BaseController
  def index
    @testimonials = Testimonial.ordered
  end
end
