class Public::HomeController < Public::BaseController
  def index
    @testimonials = Testimonial.all
    @membership_plans = MembershipPlan.ordered
  end
end
