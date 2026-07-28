require "rails_helper"

RSpec.describe "Admin pagination bounds", type: :request do
  let(:admin) { create(:user, :admin) }

  before { sign_in(admin) }

  describe "GET /admin/kullanicilar" do
    it "falls back to the last page when the requested page is past the end" do
      usernames = create_list(:user, 12).map(&:username).push(admin.username)

      get admin_users_path(page: 999)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(usernames.max)
    end

    [ "0", "-1", "abc", "" ].each do |value|
      it "renders the first page for ?page=#{value.inspect} instead of raising" do
        get admin_users_path(page: value)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(admin.username)
      end
    end
  end

  describe "GET /admin/basvurular" do
    it "keeps the status filter applied while clamping the page" do
      create(:enrollment, status: :called, full_name: "Arayan Aday")
      create(:enrollment, status: :received, full_name: "Bekleyen Aday")

      get admin_enrollments_path(status: "called", page: 0)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Arayan Aday")
      expect(response.body).not_to include("Bekleyen Aday")
    end
  end
end
