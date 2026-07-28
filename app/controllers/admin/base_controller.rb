class Admin::BaseController < ApplicationController
  include Authentication
  include Pagy::Backend

  before_action :require_panel_access
  layout "admin"

  private

  def pagy_get_page(vars, force_integer: true)
    page = super

    force_integer ? [ page, 1 ].max : page
  end
end
