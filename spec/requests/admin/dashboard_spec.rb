require "rails_helper"

RSpec.describe "Admin Dashboard", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_root_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as admin" do
    before { sign_in(admin) }

    describe "GET /admin" do
      it "returns 200 with the resource stat cards" do
        get admin_root_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Antrenörler")
        expect(response.body).to include("Dersler")
      end

      it "lists recent lessons and testimonials by name" do
        lesson = create(:lesson, name: "Muay Thai")
        testimonial = create(:testimonial, author_name: "Ayşe Yılmaz")

        get admin_root_path

        expect(response.body).to include(lesson.name)
        expect(response.body).to include(testimonial.author_name)
      end

      it "lists new applications by name and phone number" do
        create(:enrollment, full_name: "Deniz Kaya", phone: "05321234567")

        get admin_root_path

        expect(response.body).to include("Deniz Kaya")
        expect(response.body).to include("05321234567")
      end

      it "keeps applications that have already been handled out of the new applications panel" do
        create(:enrollment, full_name: "Deniz Kaya", status: :positive)

        get admin_root_path

        expect(response.body).not_to include("Deniz Kaya")
        expect(response.body).to include("Henüz başvuru yok.")
      end

      it "renders an empty state when there is no activity" do
        get admin_root_path

        expect(response.body).to include("Henüz ders yok.")
        expect(response.body).to include("Henüz yorum yok.")
        expect(response.body).to include("Henüz başvuru yok.")
      end
    end
  end
end
