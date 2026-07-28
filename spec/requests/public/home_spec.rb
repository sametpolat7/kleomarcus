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
      get root_path

      expect(response.body).to include("<title>Kleomarcus Spor Akademi</title>")
      expect(response.body).to match(%r{<meta property="og:image" content="http[^"]+hero-desktop[^"]*">})
      expect(response.body).to include(%(<link rel="canonical" href="#{root_url}">))

      schema = JSON.parse(response.body[%r{<script type="application/ld\+json"[^>]*>(.+?)</script>}m, 1])
      expect(schema["@type"]).to eq("SportsClub")
      expect(schema["openingHoursSpecification"]).to be_present
    end
  end
end
