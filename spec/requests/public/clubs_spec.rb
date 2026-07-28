require "rails_helper"

RSpec.describe "Public Club", type: :request do
  describe "GET /kulubumuz" do
    it "renders the club page with its own title and AboutPage structured data" do
      get club_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<title>Kulübümüz | Kleomarcus Spor Akademi</title>")

      schema = JSON.parse(response.body[%r{<script type="application/ld\+json">(.+?)</script>}m, 1])
      expect(schema["@type"]).to eq("AboutPage")
    end
  end
end
