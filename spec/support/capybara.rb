require "capybara/rspec"

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end

Capybara.configure do |config|
  config.default_max_wait_time = 3
  config.server = :puma, { Silent: true }
end
