module ErrorPages
  def with_error_pages
    env_config = Rails.application.env_config
    previous = env_config.slice("action_dispatch.show_exceptions", "action_dispatch.show_detailed_exceptions")

    env_config["action_dispatch.show_exceptions"] = :all
    env_config["action_dispatch.show_detailed_exceptions"] = false

    yield
  ensure
    env_config.merge!(previous)
  end
end

RSpec.configure do |config|
  config.include ErrorPages, type: :request
end
