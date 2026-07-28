module AdminAuth
  PASSWORD = "secret123"

  def sign_in(user, password: PASSWORD)
    post admin_session_path, params: { username: user.username, password: password }

    raise "sign_in failed for #{user.username}" unless user.sessions.exists?
  end
end

RSpec.configure do |config|
  config.include AdminAuth, type: :request
end
