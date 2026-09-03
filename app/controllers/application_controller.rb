class ApplicationController < ActionController::Base
  stale_when_importmap_changes
end
