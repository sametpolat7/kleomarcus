require "rails_helper"

RSpec.describe "Public Home", type: :request do
  describe "GET /" do
    it "shows the athletes' testimonials with their author, quote and rating" do
      create(:testimonial, author_name: "ayşe yılmaz", content: "Antrenmanlar çok verimli.", rating: 4)

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ayşe Yılmaz", "Antrenmanlar çok verimli.", "A.Y.")
      expect(response.body).to include("4 yıldız değerlendirme")
    end

    it "renders the SEO meta tags and the club's structured data" do
      get root_path

      expect(response.body).to include("<title>Kleomarcus Spor Akademi</title>")
      expect(response.body).to match(%r{<meta property="og:image" content="http[^"]+hero-desktop[^"]*">})
      expect(response.body).to include(%(<link rel="canonical" href="#{root_url}">))

      schema = JSON.parse(response.body[%r{<script type="application/ld\+json">(.+?)</script>}m, 1])
      expect(schema["@type"]).to eq("SportsClub")
      expect(schema["openingHoursSpecification"]).to be_present
    end
  end
end
