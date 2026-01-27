require "rails_helper"

RSpec.describe "Public::Club", type: :request do
  describe "GET /club" do
    it "returns http success" do
      get club_index_path
      expect(response).to have_http_status(:success)
    end

    it "renders the index template" do
      get club_index_path
      expect(response).to render_template(:index)
    end
  end
end
