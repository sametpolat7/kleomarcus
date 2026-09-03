require "rails_helper"

RSpec.describe "Public robots.txt", type: :request do
  describe "GET /robots.txt" do
    it "serves the crawler rules as plain text" do
      get robots_path

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/plain")
      expect(response.body).to include("User-agent: *", "Allow: /", "Disallow: /up")
    end

    it "names the AI search crawlers the club depends on" do
      get robots_path

      expect(response.body).to include("OAI-SearchBot", "Claude-SearchBot", "PerplexityBot", "Bingbot", "Googlebot")
    end

    it "points at the sitemap with an absolute canonical URL" do
      get robots_path

      expect(response.body).to include("Sitemap: https://kleomarcus.com/sitemap.xml")
    end

    it "expires within the hour so an edit reaches the edge cache without a purge" do
      get robots_path

      expect(response.headers["cache-control"]).to include("max-age=3600", "public")
    end
  end
end
