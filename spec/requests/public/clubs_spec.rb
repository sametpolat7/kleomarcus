require "rails_helper"

RSpec.describe Public::ClubsController, type: :request do
  describe "GET /club" do
    before { get club_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns HTML content" do
      expect(response.content_type).to match(%r{text/html})
    end

    context "response content" do
      it "includes club page title" do
        expect(response.body).to include("Kulübümüz")
      end

      it "includes meta description" do
        expect(response.body).to match(/<meta name="description"/)
      end

      it "includes Kleomarcus Spor Akademi" do
        expect(response.body).to include("Kleomarcus Spor Akademi")
      end
    end

    context "SEO optimization" do
      it "includes Open Graph meta tags" do
        expect(response.body).to include('property="og:title"')
        expect(response.body).to include('property="og:description"')
      end

      it "includes structured data for AboutPage" do
        expect(response.body).to include('application/ld+json')
        expect(response.body).to include('"@type": "AboutPage"')
      end
    end
  end

  describe "GET /club/trainers" do
    before { get trainers_club_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns HTML content" do
      expect(response.content_type).to match(%r{text/html})
    end

    context "response content" do
      it "sets correct content type" do
        expect(response.content_type).to match(%r{text/html})
      end

      it "includes charset in content type" do
        expect(response.content_type).to include("charset=utf-8")
      end
    end
  end

  describe "GET /club/schedules" do
    before { get schedules_club_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns HTML content" do
      expect(response.content_type).to match(%r{text/html})
    end

    context "response content" do
      it "sets correct content type" do
        expect(response.content_type).to match(%r{text/html})
      end
    end
  end

  describe "GET /club/gallery" do
    before { get gallery_club_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns HTML content" do
      expect(response.content_type).to match(%r{text/html})
    end

    it "sets correct charset" do
      expect(response.content_type).to include("charset=utf-8")
    end
  end
end
