require "rails_helper"

RSpec.describe "Public Club", type: :request do
  describe "GET /kulubumuz" do
    it "renders the club page with its own title and AboutPage structured data" do
      get club_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<title>Kulübümüz | Kleomarcus Spor Akademi</title>")

      schema = JSON.parse(response.body[%r{<script type="application/ld\+json"[^>]*>(.+?)</script>}m, 1])
      expect(schema["@type"]).to eq("AboutPage")
    end

    it "counts the branches, trainers and open days off the live data instead of hardcoding them" do
      create_list(:trainer, 3)
      create(:lesson, day_of_week: :monday, start_time: "10:00", end_time: "11:00")
      create(:lesson, day_of_week: :saturday, start_time: "10:00", end_time: "18:00")

      get club_path

      expect(response.body).to include(">#{Rails.configuration.x.club.disciplines.size}</span>")
      expect(response.body).to include(">3</span>")
      expect(response.body).to include(">2</span>")
    end

    it "states the founding year in the prose and in the structured data" do
      get club_path

      expect(response.body).to include("2019 yılından beri")

      schema = JSON.parse(response.body[%r{<script type="application/ld\+json"[^>]*>(.+?)</script>}m, 1])
      expect(schema.dig("mainEntity", "foundingDate")).to eq("2019")
      expect(schema.dig("mainEntity", "founder", "name")).to eq("Mazlum Orak")
      expect(schema.dig("mainEntity", "address", "streetAddress")).to eq("Esenler, Barış Cd. 1/A")
    end
  end
end
