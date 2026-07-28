require "rails_helper"

RSpec.describe Public::BaseHelper, type: :helper do
  describe "#set_seo_meta" do
    it "sets a title that combines the page title and the site name" do
      helper.set_seo_meta(title: "Antrenörlerimiz")

      expect(helper.content_for(:title)).to eq("Antrenörlerimiz | Kleomarcus Spor Akademi")
    end

    it "falls back to the site name when no title is given" do
      helper.set_seo_meta

      expect(helper.content_for(:title)).to eq("Kleomarcus Spor Akademi")
    end

    it "reuses the page description for Open Graph when no social copy is given" do
      helper.set_seo_meta(title: "Galeri", description: "Antrenmanlardan kareler.")

      expect(helper.content_for(:og_description)).to eq("Antrenmanlardan kareler.")
      expect(helper.content_for(:og_title)).to eq("Galeri | Kleomarcus Spor Akademi")
    end
  end

  describe "#structured_data_tag" do
    it "wraps the schema in a ld+json script tag" do
      result = helper.structured_data_tag({ "@type" => "WebPage", "name" => "Galeri" })

      expect(result).to have_css('script[type="application/ld+json"]', visible: false)
      expect(result).to include("WebPage")
    end

    it "escapes markup so a schema value cannot break out of the script tag" do
      result = helper.structured_data_tag({ "name" => "</script><script>alert(1)</script>" })

      expect(result).not_to include("<script>alert(1)")
      expect(result.scan("</script>").size).to eq(1)
    end
  end
end
