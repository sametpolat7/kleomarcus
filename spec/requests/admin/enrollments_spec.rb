require "rails_helper"

RSpec.describe "Admin Enrollments", type: :request do
  let(:admin) { create(:user, :admin) }

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

        get admin_enrollments_path(status: "silinmis")

        expect(response.body).to include("Zeynep Aydın")
      end
    end

    describe "GET /admin/basvurular/:id/edit" do
      it "renders the application detail inside the modal frame" do
        enrollment = create(:enrollment, full_name: "Zeynep Aydın", phone: "05321234567")

        get edit_admin_enrollment_path(enrollment)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('id="admin_modal_frame"')
        expect(response.body).to include("Zeynep Aydın")
        expect(response.body).to include("0532 123 45 67")
      end
    end

    describe "PATCH /admin/basvurular/:id" do
      it "moves the application to the chosen status and redirects to the index" do
        enrollment = create(:enrollment, status: :received)

        patch admin_enrollment_path(enrollment), params: { enrollment: { status: "positive" } }

        expect(enrollment.reload.status).to eq("positive")
        expect(response).to redirect_to(admin_enrollments_path)
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
