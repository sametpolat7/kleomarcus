require "rails_helper"

RSpec.describe Public::HomeHelper, type: :helper do
  describe "#star_rating" do
    it "fills as many stars as the rating and outlines the rest" do
      result = helper.star_rating(3)

      expect(result).to have_css("svg[fill='currentColor']", count: 3)
      expect(result).to have_css("svg[fill='none']", count: 2)
    end

    it "fills all five stars when no rating is given" do
      expect(helper.star_rating).to have_css("svg[fill='currentColor']", count: 5)
    end

    it "describes the rating to screen readers" do
      expect(helper.star_rating(4)).to have_css("[role='img'][aria-label='4 yıldız değerlendirme']")
    end
  end
end
