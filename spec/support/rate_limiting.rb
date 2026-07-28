RSpec.configure do |config|
  config.before(:each, type: :request) { ActionController::Base.cache_store.clear }
  config.before(:each, type: :system) { ActionController::Base.cache_store.clear }
end
