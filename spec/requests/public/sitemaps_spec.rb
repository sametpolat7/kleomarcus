require "rails_helper"

RSpec.describe "Public Sitemap", type: :request do
  describe "GET /sitemap.xml" do
    it "lists every public page as an absolute canonical URL" do
      get sitemap_path

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/xml")

      locations = response.body.scan(%r{<loc>(.+?)</loc>}).flatten
      expect(locations).to contain_exactly(
        "https://kleomarcus.com/",
        "https://kleomarcus.com/kulubumuz",
        "https://kleomarcus.com/egitmenlerimiz",
        "https://kleomarcus.com/derslerimiz",
        "https://kleomarcus.com/galeri",
        "https://kleomarcus.com/basinda-biz",
        "https://kleomarcus.com/basvuru"
      )
    end

    it "stamps lastmod from the records a page renders" do
      trainer = create(:trainer)

      get sitemap_path

      trainers_entry = response.body[%r{<url>\s*<loc>https://kleomarcus\.com/egitmenlerimiz</loc>\s*<lastmod>(.+?)</lastmod>}m, 1]
      expect(trainers_entry).to eq(trainer.updated_at.utc.iso8601)
    end

    it "omits lastmod for pages with no records behind them" do
      get sitemap_path

      gallery_entry = response.body[%r{<url>\s*<loc>https://kleomarcus\.com/galeri</loc>(.*?)</url>}m, 1]
      expect(gallery_entry).not_to include("lastmod")
    end

    it "is reachable by the crawlers the browser gate would reject" do
      get sitemap_path, headers: { "HTTP_USER_AGENT" => "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko); compatible; PerplexityBot/1.0; +https://perplexity.ai/perplexitybot Chrome/119.0.0.0 Safari/537.36" }

      expect(response).to have_http_status(:ok)
    end
  end
end
