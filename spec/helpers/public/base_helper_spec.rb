require "rails_helper"

RSpec.describe Public::BaseHelper, type: :helper do
  describe "#star_rating" do
    context "with default parameters" do
      it "renders 5 full stars by default" do
        result = helper.star_rating
        expect(result).to have_css("svg.w-5.h-5.text-primary[fill='currentColor']", count: 5)
      end
    end

    context "with full star ratings" do
      it "renders 4 full stars correctly" do
        result = helper.star_rating(4)
        expect(result).to have_css("svg[fill='currentColor']", count: 4)
        expect(result).to have_css("svg[fill='none']", count: 1)
      end

      it "renders 3 full stars correctly" do
        result = helper.star_rating(3)
        expect(result).to have_css("svg[fill='currentColor']", count: 3)
        expect(result).to have_css("svg[fill='none']", count: 2)
      end

      it "renders 1 full star correctly" do
        result = helper.star_rating(1)
        expect(result).to have_css("svg[fill='currentColor']", count: 1)
        expect(result).to have_css("svg[fill='none']", count: 4)
      end
    end

    context "edge cases" do
      it "handles zero rating" do
        result = helper.star_rating(0)
        expect(result).to have_css("svg[fill='none']", count: 5)
      end

      it "handles maximum rating" do
        result = helper.star_rating(5)
        expect(result).to have_css("svg[fill='currentColor']", count: 5)
      end

      it "returns safe HTML" do
        result = helper.star_rating
        expect(result).to be_html_safe
      end
    end
  end

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
