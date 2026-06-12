class Public::SwimsController < Public::BaseController
  def new
    @swim = Swim.new
  end

  def create
    @swim = Swim.new(swim_params)

    if @swim.save
      SwimMailer.new_application(@swim).deliver_later
      session[:swim_application_completed] = true
      redirect_to swim_thanks_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thanks
    redirect_to new_swim_path unless session.delete(:swim_application_completed)
  end

  private

  def swim_params
    params.expect(swim: [ :full_name, :phone, :email, :age, :level, :message, :info_consent, :kvkk_consent ])
  end
end
