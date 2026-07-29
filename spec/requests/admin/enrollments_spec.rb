require "rails_helper"

RSpec.describe "Admin Enrollments", type: :request do
  let(:admin) { create(:user, :admin) }

  def in_modal(selector)
    Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame #{selector}")
  end

  def detail(label)
    in_modal("dl").css("dt").find { |dt| dt.text.strip == label }.next_element
  end

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_enrollments_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as admin" do
    before { sign_in(admin) }

    describe "GET /admin/basvurular" do
      it "lists every application, newest first" do
        create(:enrollment, full_name: "Kerem Doğan", created_at: 2.days.ago)
        create(:enrollment, full_name: "Zeynep Aydın", created_at: 1.hour.ago)

        get admin_enrollments_path

        expect(response).to have_http_status(:ok)
        expect(response.body.index("Zeynep Aydın")).to be < response.body.index("Kerem Doğan")
      end

      it "narrows the list down to the requested status" do
        create(:enrollment, full_name: "Zeynep Aydın", status: :called)
        create(:enrollment, full_name: "Kerem Doğan", status: :received)

        get admin_enrollments_path(status: "called")

        expect(response.body).to include("Zeynep Aydın")
        expect(response.body).not_to include("Kerem Doğan")
      end

      it "ignores a status that is not a known enrollment status" do
        create(:enrollment, full_name: "Zeynep Aydın", status: :called)

        get admin_enrollments_path(status: "invalid_status")

        expect(response.body).to include("Zeynep Aydın")
      end
    end

    describe "GET /admin/basvurular/:id/edit" do
      it "renders the application detail inside the modal frame" do
        enrollment = create(:enrollment, full_name: "Zeynep Aydın", phone: "05321234567")

        get edit_admin_enrollment_path(enrollment)

        expect(response).to have_http_status(:ok)
        expect(Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame form")).to be_present
        expect(response.body).to include("Zeynep Aydın")
        expect(response.body).to include("0532 123 45 67")
      end

      it "fences the applicant's address off from Cloudflare's obfuscation" do
        enrollment = create(:enrollment, email: "zeynep@example.com")

        get edit_admin_enrollment_path(enrollment)

        expect(detail("E-posta").inner_html.strip)
          .to start_with("<!--email_off-->").and end_with("<!--/email_off-->")
        expect(detail("E-posta").text.strip).to eq("zeynep@example.com")
      end

      it "fences an address the applicant typed into their message too" do
        enrollment = create(:enrollment, message: "Bana zeynep@example.com adresinden ulaşın.")

        get edit_admin_enrollment_path(enrollment)

        expect(detail("Mesaj").inner_html)
          .to eq("<!--email_off-->Bana zeynep@example.com adresinden ulaşın.<!--/email_off-->")
      end

      it "shows a dash instead of the markers when the applicant gave no address" do
        enrollment = create(:enrollment, email: nil, message: nil)

        get edit_admin_enrollment_path(enrollment)

        expect(in_modal(%(a[href^="mailto:"]))).to be_nil
        expect(detail("E-posta").text.strip).to eq("—")
        expect(detail("E-posta").inner_html).not_to include("email_off")
      end
    end

    describe "PATCH /admin/basvurular/:id" do
      it "moves the application to the chosen status and redirects to the index" do
        enrollment = create(:enrollment, status: :received)

        patch admin_enrollment_path(enrollment), params: { enrollment: { status: "positive" } }

        expect(enrollment.reload.status).to eq("positive")
        expect(response).to redirect_to(admin_enrollments_path)
      end

      it "re-renders the form with an error when the status is not one the panel offers" do
        enrollment = create(:enrollment, status: :received)

        patch admin_enrollment_path(enrollment), params: { enrollment: { status: "invalid_status" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("hata oluştu")
        expect(enrollment.reload.status).to eq("received")
      end

      it "leaves the applicant's own answers untouched" do
        enrollment = create(:enrollment, full_name: "Zeynep Aydın")

        patch admin_enrollment_path(enrollment), params: {
          enrollment: { status: "called", full_name: "Başkası", phone: "05000000000" }
        }

        expect(enrollment.reload).to have_attributes(status: "called", full_name: "Zeynep Aydın")
      end
    end

    describe "DELETE /admin/basvurular/:id" do
      it "deletes the application and redirects to the index" do
        enrollment = create(:enrollment)

        expect {
          delete admin_enrollment_path(enrollment)
        }.to change(Enrollment, :count).by(-1)

        expect(response).to redirect_to(admin_enrollments_path)
      end
    end
  end
end
