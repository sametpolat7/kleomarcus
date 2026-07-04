require "rails_helper"

RSpec.describe "Admin Lessons", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:trainer) { create(:trainer) }

  let(:valid_params) do
    {
      name: "Spec Lesson",
      day_of_week: "monday",
      start_time: "09:00",
      end_time: "10:00",
      kind: "solo",
      trainer_id: trainer.id
    }
  end

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_lessons_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as admin" do
    before { sign_in(admin) }

    describe "GET /admin/dersler" do
      it "returns 200 and wires the + Yeni link to the modal frame" do
        get admin_lessons_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('id="admin-modal"')
        expect(response.body).to include('id="admin_modal_frame"')
        expect(response.body).to include('data-turbo-frame="admin_modal_frame"')
      end
    end

    describe "GET /admin/dersler/new" do
      it "returns 200 with the form wrapped in the modal turbo-frame" do
        get new_admin_lesson_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('id="admin_modal_frame"')
        expect(response.body).to include("Yeni Ders")
      end
    end

    describe "POST /admin/dersler with valid params" do
      it "creates the lesson and redirects to the index" do
        expect {
          post admin_lessons_path, params: { lesson: valid_params }
        }.to change(Lesson, :count).by(1)

        expect(response).to redirect_to(admin_lessons_path)
      end
    end

    describe "POST /admin/dersler with invalid params" do
      it "returns 422 with the error block (so Turbo can replace the frame)" do
        expect {
          post admin_lessons_path, params: { lesson: valid_params.merge(name: "") }
        }.not_to change(Lesson, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("hata oluştu")
      end
    end

    describe "PATCH /admin/dersler/:id" do
      it "updates the lesson and redirects to the index" do
        lesson = create(:lesson)

        patch admin_lesson_path(lesson), params: { lesson: { name: "Renamed Lesson" } }

        expect(lesson.reload.name).to eq("Renamed Lesson")
        expect(response).to redirect_to(admin_lessons_path)
      end
    end

    describe "DELETE /admin/dersler/:id" do
      it "deletes the lesson and redirects to the index" do
        lesson = create(:lesson)

        expect {
          delete admin_lesson_path(lesson)
        }.to change(Lesson, :count).by(-1)

        expect(response).to redirect_to(admin_lessons_path)
      end
    end
  end
end
