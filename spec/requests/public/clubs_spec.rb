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

  describe "GET /club/trainers" do
    it "returns http success" do
      get trainers_club_path
      expect(response).to have_http_status(:success)
    end

    it "renders the trainers template" do
      get trainers_club_path
      expect(response).to render_template(:trainers)
    end
  end

  describe "GET /club/schedules" do
    it "returns http success" do
      get schedules_club_path
      expect(response).to have_http_status(:success)
    end

    it "renders the schedules template" do
      get schedules_club_path
      expect(response).to render_template(:schedules)
    end
  end

  describe "GET /club/gallery" do
    it "returns http success" do
      get gallery_club_path
      expect(response).to have_http_status(:success)
    end

    it "renders the gallery template" do
      get gallery_club_path
      expect(response).to render_template(:gallery)
    end
  end
end
