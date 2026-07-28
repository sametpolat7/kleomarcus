module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    resume_session
  end

  def require_authentication
    resume_session || request_authentication
  end

  def require_panel_access
    return if Current.user&.panel_access?

    terminate_session if Current.session
    redirect_to new_admin_session_path, alert: "Bu sayfaya erişim yetkiniz yok."
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    return unless (session_id = cookies.signed[:session_id])

    session = Session.find_by(id: session_id)
    return session if session && !session.expired?

    session&.destroy
    cookies.delete(:session_id)
    nil
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to unauthenticated_redirect_path
  end

  def start_new_session_for(user)
    user.sessions.expired.delete_all

    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed[:session_id] = {
        value: session.id,
        expires: session.expires_at,
        httponly: true,
        same_site: :lax
      }
    end
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
  end

  def unauthenticated_redirect_path
    new_admin_session_path
  end
end
