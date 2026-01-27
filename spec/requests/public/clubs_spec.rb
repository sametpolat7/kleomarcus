require "rails_helper"

RSpec.describe "Public::Clubs", type: :request do
  describe "GET /club" do
    it "returns http success" do
      get club_path
      expect(response).to have_http_status(:success)
    end

    it "renders the show template" do
      get club_path
      expect(response).to render_template(:show)
    end
  end
end
