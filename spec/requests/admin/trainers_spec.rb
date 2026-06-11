require "rails_helper"

RSpec.describe "Admin Trainers", type: :request do
  let(:admin) { create(:user, :admin) }

  let(:valid_params) do
    { name: "Mehmet Demir", title: "Baş Antrenör", bio: "Deneyimli antrenör." }
  end

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_trainers_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as admin" do
    before { sign_in(admin) }

    describe "GET /admin/trainers" do
      it "returns 200 and lists existing trainers" do
        trainer = create(:trainer)

        get admin_trainers_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(trainer.name)
      end
    end

    describe "GET /admin/trainers/new" do
      it "returns 200" do
        get new_admin_trainer_path

        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /admin/trainers with valid params" do
      it "creates the trainer and redirects to the index" do
        expect {
          post admin_trainers_path, params: { trainer: valid_params }
        }.to change(Trainer, :count).by(1)

        expect(response).to redirect_to(admin_trainers_path)
      end
    end

    describe "POST /admin/trainers with invalid params" do
      it "returns 422 and does not create a trainer" do
        expect {
          post admin_trainers_path, params: { trainer: valid_params.merge(name: "") }
        }.not_to change(Trainer, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("hata oluştu")
      end
    end

    describe "PATCH /admin/trainers/:id" do
      it "updates the trainer and redirects to the index" do
        trainer = create(:trainer)

        patch admin_trainer_path(trainer), params: { trainer: { title: "Kıdemli Antrenör" } }

        expect(trainer.reload.title).to eq("Kıdemli Antrenör")
        expect(response).to redirect_to(admin_trainers_path)
      end
    end

    describe "DELETE /admin/trainers/:id" do
      it "deletes the trainer and redirects to the index" do
        trainer = create(:trainer)

        expect {
          delete admin_trainer_path(trainer)
        }.to change(Trainer, :count).by(-1)

        expect(response).to redirect_to(admin_trainers_path)
      end
    end
  end
end
