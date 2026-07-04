require "rails_helper"

RSpec.describe Public::TrainersController, type: :request do
  describe "GET /egitmenlerimiz" do
    before { get trainers_path }

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
end
