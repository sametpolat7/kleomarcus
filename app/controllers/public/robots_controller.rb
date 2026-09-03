class Public::RobotsController < Public::BaseController
  def show
    expires_in 1.hour, public: true
  end
end
