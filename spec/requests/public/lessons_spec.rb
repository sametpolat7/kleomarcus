require "rails_helper"

RSpec.describe Public::LessonsController, type: :request do
  describe "GET /derslerimiz" do
    before { get lessons_path }

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
end
