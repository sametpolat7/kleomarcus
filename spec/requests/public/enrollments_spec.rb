require "rails_helper"

RSpec.describe "Public Enrollments", type: :request do
  let(:valid_params) do
    {
      full_name: "Ayşe Yılmaz",
      phone: "0532 123 45 67",
      email: "ayse@example.com",
      age: 12,
      message: "Hafta sonu grupları hakkında bilgi almak istiyorum.",
      info_consent: "1",
      kvkk_consent: "1"
    }
  end

  describe "GET /basvuru" do
    it "renders a discipline-free application form posting back to /basvuru" do
      get new_enrollment_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Başvuru Formu")
      expect(response.body).to include('action="/basvuru"')
    end
  end

  describe "POST /basvuru" do
    it "stores the application and redirects to the thank-you page" do
      expect {
        post enrollment_path, params: { enrollment: valid_params }
      }.to change(Enrollment, :count).by(1)

      expect(response).to redirect_to(thanks_enrollment_path)
      expect(Enrollment.last).to have_attributes(
        full_name: "Ayşe Yılmaz",
        phone: "05321234567",
        status: "received"
      )
    end

    it "re-renders the form with the error list when the phone number is not a mobile one" do
      expect {
        post enrollment_path, params: { enrollment: valid_params.merge(phone: "0286 123 45 67") }
      }.not_to change(Enrollment, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Lütfen aşağıdaki alanları kontrol edin")
    end

    it "refuses the application when the KVKK box is left unchecked" do
      expect {
        post enrollment_path, params: { enrollment: valid_params.merge(kvkk_consent: "0") }
      }.not_to change(Enrollment, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /basvuru/tesekkurler" do
    it "sends a visitor who has not just applied back to the form" do
      get thanks_enrollment_path

      expect(response).to redirect_to(new_enrollment_path)
    end

    it "is shown once after a successful application and not on a refresh" do
      post enrollment_path, params: { enrollment: valid_params }

      get thanks_enrollment_path
      expect(response).to have_http_status(:ok)

      get thanks_enrollment_path
      expect(response).to redirect_to(new_enrollment_path)
    end
  end
end
