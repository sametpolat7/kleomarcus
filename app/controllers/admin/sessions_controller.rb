class Admin::SessionsController < Admin::BaseController
  allow_unauthenticated_access only: %i[new create]
  skip_before_action :require_panel_access, only: %i[new create]
  before_action :redirect_signed_in_users, only: %i[new create]
  rate_limit to: 10,
             within: 3.minutes,
             only: :create,
             with: -> { redirect_to new_admin_session_path, alert: "Lütfen daha sonra tekrar deneyin." }

  def new; end

  def create
    user = User.authenticate_by(credentials)

    if user&.panel_access?
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_admin_session_path, alert: "Lütfen geçerli bir kullanıcı adı ve şifre girin."
    end
  end

  def destroy
    terminate_session
    redirect_to new_admin_session_path, status: :see_other
  end

  private

  def redirect_signed_in_users
    redirect_to admin_root_path if authenticated? && Current.user.panel_access?
  end

  def credentials
    params.permit(:username, :password)
          .to_h
          .transform_values { |value| value.is_a?(String) ? value : "" }
          .reverse_merge("username" => "", "password" => "")
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || admin_root_url
  end
end
