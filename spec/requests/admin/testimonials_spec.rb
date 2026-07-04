require "rails_helper"

RSpec.describe "Admin Testimonials", type: :request do
  let(:admin) { create(:user, :admin) }

  let(:valid_params) do
    { author_name: "Zeynep Kaya", title: "Harika Deneyim", content: "Çok memnun kaldım.", rating: 5 }
  end

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_testimonials_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as admin" do
    before { sign_in(admin) }

    describe "GET /admin/yorumlar" do
      it "returns 200 and lists existing testimonials" do
        testimonial = create(:testimonial)

        get admin_testimonials_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(testimonial.author_name)
      end
    end

    describe "GET /admin/yorumlar/new" do
      it "returns 200" do
        get new_admin_testimonial_path

        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /admin/yorumlar with valid params" do
      it "creates the testimonial and redirects to the index" do
        expect {
          post admin_testimonials_path, params: { testimonial: valid_params }
        }.to change(Testimonial, :count).by(1)

        expect(response).to redirect_to(admin_testimonials_path)
      end
    end

    describe "POST /admin/yorumlar with invalid params" do
      it "returns 422 when the rating is out of range" do
        expect {
          post admin_testimonials_path, params: { testimonial: valid_params.merge(rating: 6) }
        }.not_to change(Testimonial, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("hata oluştu")
      end
    end

    describe "PATCH /admin/yorumlar/:id" do
      it "updates the testimonial and redirects to the index" do
        testimonial = create(:testimonial)

        patch admin_testimonial_path(testimonial), params: { testimonial: { content: "Güncellenmiş içerik." } }

        expect(testimonial.reload.content).to eq("Güncellenmiş içerik.")
        expect(response).to redirect_to(admin_testimonials_path)
      end
    end

    describe "DELETE /admin/yorumlar/:id" do
      it "deletes the testimonial and redirects to the index" do
        testimonial = create(:testimonial)

        expect {
          delete admin_testimonial_path(testimonial)
        }.to change(Testimonial, :count).by(-1)

        expect(response).to redirect_to(admin_testimonials_path)
      end
    end
  end
end
