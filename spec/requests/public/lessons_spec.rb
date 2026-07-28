require "rails_helper"

RSpec.describe "Public Lessons", type: :request do
  def slot_cells(time)
    row = Nokogiri::HTML(response.body).css("table tbody tr").find { |tr| tr.text.include?(time) }
    day_cells = row.css("td").drop(1).map { |cell| cell.text.squish }

    Lesson.schedule_days.zip(day_cells).to_h
  end

  describe "GET /derslerimiz" do
    it "puts each lesson's kind in its own day and time slot" do
      create(:lesson, :team, day_of_week: :monday, start_time: "19:15", end_time: "20:15")
      create(:lesson, day_of_week: :tuesday, start_time: "09:00", end_time: "10:00", kind: :solo)

      get lessons_path

      expect(response).to have_http_status(:ok)
      expect(slot_cells("19:15-20:15")).to include("monday" => "Grup Antrenmanı", "tuesday" => "—")
      expect(slot_cells("09:00-10:00")).to include("tuesday" => "Özel Ders", "monday" => "—")
    end

    it "still renders when there is no schedule to show yet" do
      get lessons_path

      expect(response).to have_http_status(:ok)
    end
  end
end
