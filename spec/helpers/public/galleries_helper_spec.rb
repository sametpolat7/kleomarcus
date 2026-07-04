require "rails_helper"

RSpec.describe Public::GalleriesHelper, type: :helper do
  describe "#gallery_images" do
    let(:images) { helper.gallery_images }

    it "returns an array of images" do
      expect(images).to be_an(Array)
    end

    it "includes src and alt for each image" do
      images.each do |image|
        expect(image).to have_key(:src)
        expect(image).to have_key(:alt)
      end
    end

    context "accessibility" do
      it "provides alt text for all images" do
        images.each do |image|
          expect(image[:alt]).to be_a(String)
          expect(image[:alt]).not_to be_empty
        end
      end
    end
  end
end
