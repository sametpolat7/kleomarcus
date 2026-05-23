class Public::HomeController < ApplicationController
  def index
    @testimonials = Testimonial.ordered
  end
end
