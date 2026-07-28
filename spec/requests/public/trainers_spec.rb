require "rails_helper"

RSpec.describe "Public Trainers", type: :request do
  describe "GET /egitmenlerimiz" do
    it "lists the trainers in their panel order, with title, bio and disciplines" do
      boks = create(:discipline, name: "Boks")
      first = create(:trainer, name: "Mehmet Demir", title: "Baş Antrenör", bio: "On yıllık ring deneyimi.")
      first.disciplines << boks
      second = create(:trainer, name: "Elif Kaya", title: "Kondisyon Antrenörü")

      get trainers_path

      expect(response).to have_http_status(:ok)
      expect(response.body.index(first.name)).to be < response.body.index(second.name)
      expect(response.body).to include("Baş Antrenör", "On yıllık ring deneyimi.", "Boks")
    end

    it "still renders when there is no trainer to list yet" do
      get trainers_path

      expect(response).to have_http_status(:ok)
    end
  end
end
