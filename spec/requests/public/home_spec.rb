require "rails_helper"

RSpec.describe Public::HomeController, type: :request do
  describe "GET /" do
    before { get root_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns HTML content" do
      expect(response.content_type).to match(%r{text/html})
    end

    context "response content" do
      it "includes Kleomarcus in the page title" do
        expect(response.body).to include("Kleomarcus")
      end

      it "includes meta description" do
        expect(response.body).to match(/<meta name="description"/)
      end

      it "includes meta keywords" do
        expect(response.body).to match(/<meta name="keywords"/)
      end
    end

    context "SEO optimization" do
      it "includes Open Graph meta tags" do
        expect(response.body).to include('property="og:title"')
        expect(response.body).to include('property="og:description"')
        expect(response.body).to include('property="og:image"')
      end

      it "includes structured data (JSON-LD)" do
        expect(response.body).to include('application/ld+json')

        json_ld_match = response.body.match(/<script type="application\/ld\+json">(.+?)<\/script>/m)
        expect(json_ld_match).to be_present

        structured_data = JSON.parse(json_ld_match[1])
        expect(structured_data["@type"]).to eq("SportsClub")
      end

      it "includes canonical URL" do
        expect(response.body).to match(/<link rel="canonical"/)
      end
    end

    context "response headers" do
      it "sets correct content type" do
        expect(response.content_type).to match(%r{text/html})
      end

      it "includes charset in content type" do
        expect(response.content_type).to include("charset=utf-8")
      end
    end

    context "performance and caching" do
      it "sets Cache-Control header" do
        expect(response.headers["Cache-Control"]).to be_present
      end
    end
  end
end
