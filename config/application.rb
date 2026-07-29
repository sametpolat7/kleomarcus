require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Kleomarcus
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    # lib/middleware is excluded because middleware has to be a real constant by the time the
    # stack is built, which happens before Zeitwerk can autoload anything — so those files are
    # required explicitly instead (see config/environments/production.rb).
    config.autoload_lib(ignore: %w[assets middleware tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.i18n.default_locale = :tr
    config.i18n.available_locales = [ :tr, :en ]

    # With config.action_controller.include_all_helpers = false, each controller only includes its own matching helper module (e.g. UsersController gets UsersHelper) instead of all app/helpers modules, so helpers aren't globally shared across controllers.
    config.action_controller.include_all_helpers = false

    # Serve branded error pages for everything that reaches ActionDispatch::ShowExceptions,
    # which rewrites PATH_INFO to "/<status>" before calling this app. Rails has already
    # mapped the exception to a status code by then, so there is nothing to classify here
    # and no controller needs a rescue_from.
    #
    # Resolving the parameter memos up front is load-bearing rather than defensive:
    # ActionController::Instrumentation reads request.filtered_parameters for every action
    # and rescues only ParseError, while Request#GET raises the sibling
    # ActionController::BadRequest for a malformed query string — one of the very requests
    # this page has to render. Seeding empty params in that case keeps the branded 400 from
    # double-faulting into the static page.
    #
    # If the branded page itself cannot render — a stale asset manifest after a bad deploy,
    # say — fall back to the static pages in public/. ShowExceptions wraps this whole call
    # in its own rescue, so Rails' plain-text failsafe still sits underneath.
    config.exceptions_app = lambda do |env|
      request = ActionDispatch::Request.new(env)

      begin
        request.GET
        request.POST
      rescue ActionController::BadRequest, ActionDispatch::Http::Parameters::ParseError
        env["action_dispatch.request.query_parameters"] ||= {}
        env["action_dispatch.request.request_parameters"] ||= {}
      end

      ErrorsController.action(:show).call(env)
    rescue Exception => rendering_error
      Rails.logger&.error { "[errors] error page failed to render: #{rendering_error.class}: #{rendering_error.message}" }

      ActionDispatch::PublicExceptions.new(Rails.public_path).call(env)
    end
  end
end
