require "rails_helper"

RSpec.describe Public::BaseHelper, type: :helper do
  describe "#organization_schema" do
    subject(:schema) { helper.organization_schema }

    it "returns the SportsClub structured data" do
      expect(schema[:"@type"]).to eq("SportsClub")
      expect(schema[:name]).to eq("Kleomarcus Spor Akademi")
    end
  end

  describe "#structured_data_tag" do
    it "wraps the schema in a ld+json script tag" do
      result = helper.structured_data_tag({ "@type" => "WebPage", "name" => "Test" })

      expect(result).to have_css('script[type="application/ld+json"]', visible: false)
      expect(result).to include("WebPage")
      expect(result).to be_html_safe
    end
  end

  describe "#set_seo_meta" do
    it "sets a title that combines the page title and the site name" do
      helper.set_seo_meta(title: "Antrenörlerimiz")

      expect(helper.content_for(:title)).to eq("Antrenörlerimiz | Kleomarcus Spor Akademi")
    end

    it "falls back to the site name when no title is given" do
      helper.set_seo_meta

      expect(helper.content_for(:title)).to eq("Kleomarcus Spor Akademi")
    end
  end
end
