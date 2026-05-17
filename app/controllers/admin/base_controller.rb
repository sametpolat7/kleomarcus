class Admin::BaseController < ApplicationController
  include Authentication

  layout "admin"

  def unauthenticated_redirect_path
    new_admin_session_path
  end
end
