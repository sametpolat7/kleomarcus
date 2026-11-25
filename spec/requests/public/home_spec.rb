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

    it "lists the membership plans in panel order with their monthly price and features" do
      create(:membership_plan, name: "Özel Ders 2", monthly_price: 12_000, position: 3)
      create(:membership_plan, name: "Grup Dersleri", monthly_price: 2_500, position: 2, features: [ "Haftada 2, ayda 8 grup dersi", "Ekiple birlikte sparring" ])
      create(:membership_plan, name: "Özel Ders 1", monthly_price: 8_000, position: 1)

      get root_path

      cards = Nokogiri::HTML(response.body).css("section#membership article")
      expect(cards.map { |card| card.at_css("h3").text }).to eq([ "Özel Ders 1", "Grup Dersleri", "Özel Ders 2" ])
      expect(cards.map { |card| card.at_css("[aria-label^='Aylık']")["aria-label"] })
        .to eq([ "Aylık 8.000 lira", "Aylık 2.500 lira", "Aylık 12.000 lira" ])
      expect(cards[1].text).to include("₺2.500")
      expect(cards[1].css("li").map { |item| item.text.squish }).to eq([ "Haftada 2, ayda 8 grup dersi", "Ekiple birlikte sparring" ])
    end

    it "badges only the featured plan as Popüler" do
      create(:membership_plan, name: "Özel Ders 1", position: 1)
      create(:membership_plan, :featured, name: "Grup Dersleri", position: 2)

      get root_path

      cards = Nokogiri::HTML(response.body).css("section#membership article")
      expect(cards.map { |card| card.text.include?("Popüler") }).to eq([ false, true ])
    end

    it "drops the whole membership section when there is no plan to show" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(%(id="membership"))
      expect(response.body).not_to include("Üyelik Paketleri")
    end

    it "renders the SEO meta tags and the club's structured data" do
      create(:lesson, day_of_week: :monday, start_time: "10:00", end_time: "11:00")
      create(:lesson, day_of_week: :monday, start_time: "21:15", end_time: "22:15")

      get root_path

      expect(response.body).to include("<title>Çanakkale Dövüş Sporları Kulübü | Kleomarcus Spor Akademi</title>")
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

    it "declares the combat disciplines as the club's sport and keeps conditioning out of it" do
      get root_path

      schema = JSON.parse(response.body[%r{<script type="application/ld\+json"[^>]*>(.+?)</script>}m, 1])

      expect(schema["sport"]).to eq([ "Boks", "Kick Boks", "Muay Thai", "Wushu", "MMA" ])
      expect(schema["sport"]).not_to include("CrossFit", "Hyrox", "Bodybuilding")
      expect(schema["alternateName"]).to include("Kleomarcus Dövüş Kulübü")
      expect(schema["keywords"]).to include("çanakkale dövüş kulübü")
      expect(schema["keywords"]).not_to include("spor salonu")
    end

    it "catalogues the conditioning sets under a separate, subordinate catalogue" do
      get root_path

      schema = JSON.parse(response.body[%r{<script type="application/ld\+json"[^>]*>(.+?)</script>}m, 1])
      catalogues = schema.dig("hasOfferCatalog", "itemListElement")

      expect(catalogues.map { |c| c["name"] }).to eq([ "Dövüş Branşları", "Güç ve Kondisyon Antrenmanları" ])
      expect(catalogues.first["itemListElement"].map { |o| o.dig("itemOffered", "name") })
        .to eq([ "Boks", "Kick Boks", "Muay Thai", "Wushu", "MMA" ])
      expect(catalogues.second["itemListElement"].map { |o| o.dig("itemOffered", "name") })
        .to eq([ "CrossFit", "Hyrox", "Bodybuilding" ])
    end

    it "publishes the upcoming second location as a department of the same organisation" do
      get root_path

      schema = JSON.parse(response.body[%r{<script type="application/ld\+json"[^>]*>(.+?)</script>}m, 1])
      department = schema["department"]

      expect(department["name"]).to eq("Kleomarcus Plus")
      expect(department.dig("address", "streetAddress")).to eq("Esenler-Karacaören Yolu Üzeri")
      expect(department.dig("parentOrganization", "@id")).to eq("https://kleomarcus.com/#organization")
    end

    it "stops advertising the club as a spor salonu through a keywords meta tag" do
      get root_path

      expect(response.body).not_to include(%(<meta name="keywords"))
      expect(response.body).not_to include("spor salonu çanakkale")
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
