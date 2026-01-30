require "rails_helper"

RSpec.describe Public::HomeHelper, type: :helper do
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

    context "with half star ratings" do
      it "renders 4.5 stars (4 full, 1 half, 0 empty)" do
        result = helper.star_rating(4.5)
        expect(result).to have_css("svg[fill='currentColor']", count: 4)
        expect(result).to have_css("svg path[fill='url(#half-star-gradient)']", count: 1)
      end

      it "renders 3.5 stars (3 full, 1 half, 1 empty)" do
        result = helper.star_rating(3.5)
        expect(result).to have_css("svg[fill='currentColor']", count: 3)
        expect(result).to have_css("svg path[fill='url(#half-star-gradient)']", count: 1)
        expect(result).to have_css("svg[fill='none']", count: 1)
      end

      it "renders half star with gradient definition" do
        result = helper.star_rating(4.5)
        expect(result).to include("half-star-gradient")
        expect(result).to include("linearGradient")
      end
    end

    context "with decimal ratings rounded to half" do
      it "rounds 4.7 to 4.5 (displays half star)" do
        result = helper.star_rating(4.7)
        expect(result).to have_css("svg[fill='currentColor']", count: 4)
        expect(result).to have_css("svg path[fill='url(#half-star-gradient)']", count: 1)
      end

      it "rounds 4.3 to 4 (no half star)" do
        result = helper.star_rating(4.3)
        expect(result).to have_css("svg[fill='currentColor']", count: 4)
        expect(result).to have_css("svg[fill='none']", count: 1)
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
end
