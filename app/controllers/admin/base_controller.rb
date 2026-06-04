class Admin::BaseController < ApplicationController
  include Authentication
  include Pagy::Backend

  before_action :require_panel_access

  layout "admin"
end
