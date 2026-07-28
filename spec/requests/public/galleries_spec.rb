require "rails_helper"

RSpec.describe "Public Gallery", type: :request do
  include Public::GalleriesHelper

  describe "GET /galeri" do
    it "renders every gallery image as a lightbox item, each with alt text" do
      get gallery_path

      expect(response).to have_http_status(:ok)
      expect(gallery_images).not_to be_empty
      expect(response.body.scan('data-gallery-target="item"').size).to eq(gallery_images.size)

      gallery_images.each do |image|
        expect(image[:alt]).to be_present
        expect(response.body).to include(image[:alt])
      end
    end
  end
end
