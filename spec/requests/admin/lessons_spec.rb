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
      it "opens the new-lesson form in the modal frame rather than a page of its own" do
        get admin_lessons_path

        expect(response).to have_http_status(:ok)
        trigger = Nokogiri::HTML(response.body).at_css("a[href='#{new_admin_lesson_path}']")
        expect(trigger[:"data-turbo-frame"]).to eq("admin_modal_frame")
      end

      it "shows each lesson with its trainer in the weekly calendar" do
        create(:lesson, name: "Muay Thai", day_of_week: :monday, start_time: "19:15", end_time: "20:15",
                        trainer: create(:trainer, name: "Mehmet Demir"))

        get admin_lessons_path

        expect(response.body).to include("Muay Thai", "Mehmet Demir")
      end

      it "points every empty slot at the new-lesson form for that slot" do
        create(:lesson, day_of_week: :monday, start_time: "19:15", end_time: "20:15")

        get admin_lessons_path

        links = Nokogiri::HTML(response.body).css("a[href*='/admin/dersler/new']").map { |link| link[:href] }
        expect(links).to include(
          new_admin_lesson_path(day_of_week: "tuesday", start_time: "19:15", end_time: "20:15")
        )
      end

      it "renders the empty state when there is nothing on the schedule yet" do
        get admin_lessons_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Henüz ders eklenmemiş")
        expect(Nokogiri::HTML(response.body).css("div.sticky.text-right")).to be_empty
      end

      it "draws lessons that share a start time once each rather than once per end time" do
        genclar = create(:lesson, name: "Gençler", day_of_week: :monday, start_time: "18:15", end_time: "19:15")
        yogun = create(:lesson, name: "Yoğun", day_of_week: :monday, start_time: "18:15", end_time: "20:00")

        get admin_lessons_path

        expect(response).to have_http_status(:ok)
        page = Nokogiri::HTML(response.body)

        [ genclar, yogun ].each do |lesson|
          expect(page.css("a[href='#{edit_admin_lesson_path(lesson)}']").size).to eq(2)
        end

        expect(response.body.scan("Gençler").size).to eq(4)
        expect(response.body.scan("Yoğun").size).to eq(4)

        hour_rows = page.css("div.sticky.text-right")
        expect(hour_rows.size).to eq(1)
        expect(hour_rows.first.text.split).to eq([ "18:15", "20:00" ])
      end
    end

    describe "GET /admin/dersler/new" do
      it "returns 200 with the form wrapped in the modal turbo-frame" do
        get new_admin_lesson_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Yeni Ders")
        expect(Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame form")).to be_present
      end

      it "prefills the slot the admin clicked in the calendar" do
        get new_admin_lesson_path(day_of_week: "wednesday", start_time: "18:00", end_time: "19:00")

        form = Nokogiri::HTML(response.body)
        expect(form.at_css("select[name='lesson[day_of_week]'] option[selected]")[:value]).to eq("wednesday")
        expect(form.at_css("input[name='lesson[start_time]']")[:value]).to start_with("18:00")
        expect(form.at_css("input[name='lesson[end_time]']")[:value]).to start_with("19:00")
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

      it "rejects a day_of_week outside the enum instead of raising out of the controller" do
        expect {
          post admin_lessons_path, params: { lesson: valid_params.merge(day_of_week: "notaday") }
        }.not_to change(Lesson, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Gün kabul edilen bir kelime değil")
        expect(Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame form")).to be_present
      end

      it "rejects a kind outside the enum instead of raising out of the controller" do
        expect {
          post admin_lessons_path, params: { lesson: valid_params.merge(kind: "hybrid") }
        }.not_to change(Lesson, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Tür kabul edilen bir kelime değil")
      end

      it "rejects a blank kind — the form's “Seçin” prompt — with the presence message" do
        expect {
          post admin_lessons_path, params: { lesson: valid_params.merge(kind: "") }
        }.not_to change(Lesson, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Tür doldurulmalı")
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
