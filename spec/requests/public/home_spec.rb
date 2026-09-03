require "rails_helper"

RSpec.describe "Public Home", type: :request do
  describe "GET /" do
    it "shows the athletes' testimonials with their author, quote and rating" do
      create(:testimonial, author_name: "Ayşe Yılmaz", content: "Antrenmanlar çok verimli.", rating: 4)

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ayşe Yılmaz", "Antrenmanlar çok verimli.", "A.Y.")
      expect(response.body).to include("4 yıldız değerlendirme")
    end

    it "keeps the testimonials section once a single testimonial is left" do
      create(:testimonial, author_name: "Ayşe Yılmaz")

      get root_path

      expect(response).to have_http_status(:ok)
      section = Nokogiri::HTML(response.body).at_css("section#testimonials")
      expect(section.text).to include("Sporcularımızdan", "Ayşe Yılmaz")
      expect(section.css('[data-carousel-target="slide"]').size).to eq(1)
    end

    it "drops the whole testimonials section when there is nothing to show" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(%(id="testimonials"))
      expect(response.body).not_to include("Sporcularımızdan")
      expect(response.body).not_to include("Sonraki Yorum")
    end

    it "renders the SEO meta tags and the club's structured data" do
      create(:lesson, day_of_week: :monday, start_time: "10:00", end_time: "11:00")
      create(:lesson, day_of_week: :monday, start_time: "21:15", end_time: "22:15")

      get root_path

      expect(response.body).to include("<title>Kleomarcus Spor Akademi</title>")
      expect(response.body).to match(%r{<meta property="og:image" content="http[^"]+hero-desktop[^"]*">})
      expect(response.body).to include(%(<link rel="canonical" href="https://kleomarcus.com/">))

      schema = JSON.parse(response.body[%r{<script type="application/ld\+json"[^>]*>(.+?)</script>}m, 1])
      expect(schema["@type"]).to eq("SportsClub")
      expect(schema["@id"]).to eq("https://kleomarcus.com/#organization")
      expect(schema["foundingDate"]).to eq("2019")
      expect(schema.dig("address", "streetAddress")).to eq("Esenler, Barış Cd. 1/A")
      expect(schema["openingHoursSpecification"]).to eq(
        [ { "@type" => "OpeningHoursSpecification", "dayOfWeek" => [ "Monday" ], "opens" => "10:00", "closes" => "22:15" } ]
      )
    end

    it "names Çanakkale in the visible page copy the retrievers read" do
      get root_path

      text = Nokogiri::HTML(response.body).css("section").text
      expect(text.scan("Çanakkale").size).to be >= 3
    end

    it "publishes the structured-data description as plain text rather than escaped entities" do
      get root_path

      schema = JSON.parse(response.body[%r{<script type="application/ld\+json"[^>]*>(.+?)</script>}m, 1])
      expect(schema["description"]).to include("2019'dan beri Çanakkale'de")
      expect(schema["description"]).not_to include("&#39;")
    end

    it "keeps the canonical URL free of the query string" do
      get root_path, params: { utm_source: "instagram" }

      expect(response.body).to include(%(<link rel="canonical" href="https://kleomarcus.com/">))
      expect(response.body).not_to include("utm_source=instagram")
    end

    it "serves the page to clients the modern-browser gate would otherwise reject" do
      get root_path, headers: { "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36" }

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("noindex")
    end
  end
end
