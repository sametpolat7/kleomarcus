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
        create(:testimonial, author_name: "Zeynep Kaya")

        get admin_testimonials_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Zeynep Kaya")
      end
    end

    describe "GET /admin/yorumlar?page=2" do
      it "carries the overflow onto a second page" do
        oldest = create(:testimonial, author_name: "Eski Yorumcu", created_at: 1.year.ago)
        create_list(:testimonial, Pagy::DEFAULT[:limit], created_at: 1.day.ago)

        get admin_testimonials_path(page: 2)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(oldest.author_name)
      end
    end

    describe "GET /admin/yorumlar/new" do
      it "renders the blank form inside the modal turbo-frame" do
        get new_admin_testimonial_path

        expect(response).to have_http_status(:ok)
        form = Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame form")
        expect(form.css("[name]").map { |field| field[:name] })
          .to include("testimonial[author_name]", "testimonial[content]", "testimonial[rating]")
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
      it "returns 422 with the error block when a required field is left blank" do
        expect {
          post admin_testimonials_path, params: { testimonial: valid_params.merge(author_name: "") }
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
