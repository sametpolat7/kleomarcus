module AdminAuth
  PASSWORD = "secret123"

  def sign_in(user)
    post admin_session_path, params: { username: user.username, password: PASSWORD }
  end
end

RSpec.configure do |config|
  config.include AdminAuth, type: :request
end
