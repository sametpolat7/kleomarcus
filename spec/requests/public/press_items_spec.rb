require "rails_helper"

RSpec.describe "Public Press Items", type: :request do
  def schema_from(body)
    JSON.parse(body[%r{<script type="application/ld\+json"[^>]*>(.+?)</script>}m, 1])
  end

  def year_headings(body)
    body.scan(%r{<h3[^>]*text-primary[^>]*>\s*(\d{4})\s*</h3>}).flatten
  end

  describe "GET /basinda-biz" do
    it "renders only the published records" do
      create(:press_item, :visible, headline: "Yayında olan haber")
      create(:press_item, headline: "Taslak haber")

      get press_items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Yayında olan haber")
      expect(response.body).not_to include("Taslak haber")
    end

    it "groups the records under year headings, newest year first" do
      create(:press_item, :visible, published_on: Date.new(2019, 4, 26))
      create(:press_item, :visible, published_on: Date.new(2026, 7, 22))
      create(:press_item, :visible, published_on: Date.new(2026, 1, 5))

      get press_items_path

      expect(year_headings(response.body)).to eq([ "2026", "2019" ])
    end

    it "credits the publisher, the date and the reporter" do
      create(:press_item, :visible,
             publisher: "Çanakkale Olay",
             byline: "Hadiye Ayşe İrim",
             published_on: Date.new(2025, 11, 16))

      get press_items_path

      expect(response.body).to include("Çanakkale Olay", "Hadiye Ayşe İrim")
      expect(response.body).to include(%(<time datetime="2025-11-16">16 Kasım 2025</time>))
    end

    it "quotes the article and points at both the original and the archive copy" do
      create(:press_item, :visible,
             url: "https://www.canakkaleolay.com/haber/gumus-madalya-114206",
             archive_url: "https://web.archive.org/web/20251116/gumus-madalya",
             quote: "70 kilo Kadınlar Sanda Kategorisinde Balkan İkincisi olarak, gümüş madalya kazandı.")

      get press_items_path

      expect(response.body).to include("70 kilo Kadınlar Sanda Kategorisinde Balkan İkincisi")
      expect(response.body).to include("https://www.canakkaleolay.com/haber/gumus-madalya-114206")
      expect(response.body).to include("https://web.archive.org/web/20251116/gumus-madalya")
    end

    it "omits the archive link when there is no archive copy" do
      create(:press_item, :unarchived)

      get press_items_path

      expect(response.body).not_to include("Arşiv kopyası")
    end

    it "tells the visitor when nothing has been published yet" do
      create(:press_item, published: false)

      get press_items_path

      expect(response.body).to include("Yayınlanmış basın kaydı bulunmuyor.")
    end

    it "publishes each record as a NewsArticle attached to the club entity" do
      create(:press_item, :visible,
             publisher: "Çanakkale Olay",
             headline: "Kleomarcus'tan Ceyda Güven gümüş madalya ile döndü",
             url: "https://www.canakkaleolay.com/haber/gumus-madalya-114206",
             published_on: Date.new(2025, 11, 16))

      get press_items_path

      schema = schema_from(response.body)
      expect(schema["@type"]).to eq("CollectionPage")
      expect(schema.dig("mainEntity", "@id")).to eq("https://kleomarcus.com/#organization")
      expect(schema.dig("mainEntity", "subjectOf")).to contain_exactly(
        {
          "@type" => "NewsArticle",
          "headline" => "Kleomarcus'tan Ceyda Güven gümüş madalya ile döndü",
          "datePublished" => "2025-11-16",
          "url" => "https://www.canakkaleolay.com/haber/gumus-madalya-114206",
          "publisher" => { "@type" => "NewsMediaOrganization", "name" => "Çanakkale Olay" }
        }
      )
    end

    it "leaves the drafts out of the structured data too" do
      create(:press_item, :visible, headline: "Yayında olan haber")
      create(:press_item, headline: "Taslak haber")

      get press_items_path

      expect(schema_from(response.body).dig("mainEntity", "subjectOf").size).to eq(1)
    end

    it "carries its own title and a canonical URL free of the query string" do
      get press_items_path, params: { utm_source: "instagram" }

      expect(response.body).to include("<title>Basında Biz | Kleomarcus Spor Akademi</title>")
      expect(response.body).to include(%(<link rel="canonical" href="https://kleomarcus.com/basinda-biz">))
    end
  end
end
