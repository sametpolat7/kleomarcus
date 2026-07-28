class Admin::BaseController < ApplicationController
  include Authentication
  include Pagy::Backend

  before_action :require_panel_access
  after_action :keep_flash_inside_frames
  layout "admin"

  private

  def keep_flash_inside_frames
    flash.keep if turbo_frame_request?
  end

  def pagy_get_page(vars, force_integer: true)
    page = super

    force_integer ? [ page, 1 ].max : page
  end
end
