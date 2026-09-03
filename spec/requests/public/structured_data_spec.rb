require "rails_helper"

RSpec.describe "Public structured data", type: :request do
  PAGES = {
    "/kulubumuz" => "https://kleomarcus.com/kulubumuz",
    "/egitmenlerimiz" => "https://kleomarcus.com/egitmenlerimiz",
    "/derslerimiz" => "https://kleomarcus.com/derslerimiz",
    "/galeri" => "https://kleomarcus.com/galeri",
    "/basvuru" => "https://kleomarcus.com/basvuru",
    "/basinda-biz" => "https://kleomarcus.com/basinda-biz"
  }.freeze

  PAGES.each do |path, canonical|
    it "declares #{path} under the canonical URL in both the link tag and the structured data" do
      get path, params: { utm_source: "instagram" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(<link rel="canonical" href="#{canonical}">))
      expect(schema_from(response.body)["url"]).to eq(canonical)
    end
  end

  it "keeps the structured data on the apex host when the request arrives on www" do
    host! "www.kleomarcus.com"

    get "/derslerimiz"

    expect(schema_from(response.body)["url"]).to eq("https://kleomarcus.com/derslerimiz")
  end

  def schema_from(body)
    JSON.parse(body[%r{<script type="application/ld\+json"[^>]*>(.+?)</script>}m, 1])
  end
end
