require "rails_helper"

RSpec.describe Public::GalleriesController, type: :request do
  describe "GET /galeri" do
    before { get gallery_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns HTML content" do
      expect(response.content_type).to match(%r{text/html})
    end

    it "sets correct charset" do
      expect(response.content_type).to include("charset=utf-8")
    end
  end
end
