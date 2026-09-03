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

  describe "#canonical_url" do
    it "builds the URL from the canonical host and drops the query string" do
      helper.request.path = "/derslerimiz"
      helper.request.query_string = "utm_source=instagram"

      expect(helper.canonical_url).to eq("https://kleomarcus.com/derslerimiz")
    end

    it "builds a URL for paths URI parsing would choke on instead of raising" do
      helper.request.path = "/kulubumuz.%zz"

      expect(helper.canonical_url).to eq("https://kleomarcus.com/kulubumuz.%zz")
    end
  end

  describe "#seo_description" do
    it "returns the description the page set" do
      helper.set_seo_meta(description: "Antrenmanlardan kareler.")

      expect(helper.seo_description).to eq("Antrenmanlardan kareler.")
    end

    it "keeps the apostrophes unescaped so structured data stays plain text" do
      helper.set_seo_meta

      expect(helper.seo_description).to include("2019'dan beri Çanakkale'de")
      expect(helper.seo_description).not_to include("&#39;")
    end

    it "falls back to the default description when the page set none" do
      expect(helper.seo_description).to eq(helper.default_seo_description)
    end
  end

  describe "#search_console_verification_tags" do
    it "renders the Google and Bing tags once the tokens are configured" do
      allow(helper).to receive(:club).and_return(club_config(google_site_verification: "g-token", bing_site_verification: "b-token"))

      result = helper.search_console_verification_tags

      expect(result).to have_css('meta[name="google-site-verification"][content="g-token"]', visible: false)
      expect(result).to have_css('meta[name="msvalidate.01"][content="b-token"]', visible: false)
    end

    it "renders nothing while the tokens are blank" do
      expect(helper.search_console_verification_tags).to be_blank
    end

    it "skips only the provider whose token is missing" do
      allow(helper).to receive(:club).and_return(club_config(google_site_verification: "g-token"))

      result = helper.search_console_verification_tags

      expect(result).to have_css('meta[name="google-site-verification"]', visible: false)
      expect(result).not_to have_css('meta[name="msvalidate.01"]', visible: false)
    end

    def club_config(**overrides)
      Rails.configuration.x.club.dup.tap { |config| overrides.each { |key, value| config[key] = value } }
    end
  end

  describe "club disciplines" do
    it "reads the canonical branch list from the club config" do
      expect(helper.club_discipline_names).to eq(Rails.configuration.x.club.disciplines.map { |d| d[:name] })
    end

    it "splits the list into the groups the hero renders" do
      combat = helper.club_disciplines_in("combat").map { |d| d[:name] }
      fitness = helper.club_disciplines_in("fitness").map { |d| d[:name] }

      expect(combat).to include("Boks", "Muay Thai")
      expect(fitness).to include("CrossFit")
      expect(combat & fitness).to be_empty
      expect(combat.size + fitness.size).to eq(helper.club_discipline_names.size)
    end

    it "offers only the branches that carry a card image to the carousel" do
      expect(helper.featured_club_disciplines).to all(include(:image, :summary))
    end

    it "renders the prose list with a Turkish connector before the last branch" do
      result = helper.club_discipline_list

      expect(result).to have_css("span.text-primary", count: helper.club_discipline_names.size)
      expect(result).to include(" ve ")
      expect(result).to include(helper.club_discipline_names.last)
    end
  end

  describe "#club_weekend_hours" do
    it "reads the shared weekend window off the lesson schedule" do
      create(:lesson, day_of_week: :saturday, start_time: "10:00", end_time: "18:00")
      create(:lesson, day_of_week: :sunday, start_time: "10:00", end_time: "18:00")

      expect(helper.club_weekend_hours).to eq("10:00-18:00")
    end

    it "says nothing rather than a wrong hour when the two days differ" do
      create(:lesson, day_of_week: :saturday, start_time: "10:00", end_time: "18:00")
      create(:lesson, day_of_week: :sunday, start_time: "10:00", end_time: "17:00")

      expect(helper.club_weekend_hours).to be_nil
    end

    it "says nothing when the weekend has no lesson" do
      create(:lesson, day_of_week: :monday, start_time: "10:00", end_time: "11:00")

      expect(helper.club_weekend_hours).to be_nil
    end
  end

  describe "#press_schema" do
    it "maps each record to a NewsArticle node credited to its publisher" do
      item = create(:press_item,
                    publisher: "Çanakkale Olay",
                    headline: "Balkan Şampiyonasından gümüş madalya",
                    url: "https://www.canakkaleolay.com/haber/gumus-114206",
                    published_on: Date.new(2025, 11, 16))

      expect(helper.press_schema([ item ])).to eq([
        {
          "@type": "NewsArticle",
          "headline": "Balkan Şampiyonasından gümüş madalya",
          "datePublished": "2025-11-16",
          "url": "https://www.canakkaleolay.com/haber/gumus-114206",
          "publisher": { "@type": "NewsMediaOrganization", "name": "Çanakkale Olay" }
        }
      ])
    end
  end

  describe "#opening_hours_specification" do
    it "derives each day's window from the lesson schedule" do
      create(:lesson, day_of_week: :monday, start_time: "10:00", end_time: "11:00")
      create(:lesson, day_of_week: :monday, start_time: "21:15", end_time: "22:15")
      create(:lesson, day_of_week: :saturday, start_time: "10:00", end_time: "11:00")

      expect(helper.opening_hours_specification).to contain_exactly(
        { "@type": "OpeningHoursSpecification", "dayOfWeek": [ "Monday" ], "opens": "10:00", "closes": "22:15" },
        { "@type": "OpeningHoursSpecification", "dayOfWeek": [ "Saturday" ], "opens": "10:00", "closes": "11:00" }
      )
    end

    it "groups days that share the same window" do
      create(:lesson, day_of_week: :saturday, start_time: "10:00", end_time: "18:00")
      create(:lesson, day_of_week: :sunday, start_time: "10:00", end_time: "18:00")

      expect(helper.opening_hours_specification).to contain_exactly(
        { "@type": "OpeningHoursSpecification", "dayOfWeek": [ "Saturday", "Sunday" ], "opens": "10:00", "closes": "18:00" }
      )
    end

    it "returns nothing when no lesson is scheduled" do
      expect(helper.opening_hours_specification).to be_empty
    end
  end

  describe "#organization_schema" do
    it "publishes the canonical club facts under a single entity id" do
      schema = helper.organization_schema

      expect(schema[:@id]).to eq("https://kleomarcus.com/#organization")
      expect(schema[:foundingDate]).to eq("2019")
      expect(schema[:founder]).to eq({ "@type": "Person", "name": "Mazlum Orak" })
      expect(schema[:address][:streetAddress]).to eq("Esenler, Barış Cd. 1/A")
      expect(schema[:address][:postalCode]).to eq("17010")
      expect(schema[:geo]).to eq({ "@type": "GeoCoordinates", "latitude": "40.1607801", "longitude": "26.4151269" })
    end

    it "omits the opening hours when the schedule is empty" do
      expect(helper.organization_schema).not_to have_key(:openingHoursSpecification)
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
