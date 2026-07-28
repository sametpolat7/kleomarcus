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

    it "renders a single row for lessons that share a start time but not an end time" do
      create(:lesson, :team, day_of_week: :monday, start_time: "18:15", end_time: "19:15")
      create(:lesson, day_of_week: :monday, start_time: "18:15", end_time: "20:00", kind: :solo)

      get lessons_path
      expect(response).to have_http_status(:ok)
      expect(Nokogiri::HTML(response.body).css("table tbody tr").size).to eq(1)
      expect(slot_cells("18:15-20:00")).to include("monday" => "Grup Antrenmanı", "tuesday" => "—")
      expect(response.body).not_to include("18:15-19:15")
      expect(response.body.scan("18:15-20:00").size).to eq(2)
    end

    it "sends the contact links to the homepage anchor rather than a bare fragment" do
      get lessons_path

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML(response.body)
      mobile_contact = document.css("#mobile-menu a").find { |link| link.text.squish == "İletişim" }
      expect(mobile_contact["href"]).to eq(root_path(anchor: "contact"))

      contact_hrefs = document.css("a[href*='#contact']").map { |link| link["href"] }
      expect(contact_hrefs).not_to be_empty
      expect(contact_hrefs).to all(start_with("/"))
    end

    it "still renders when there is no schedule to show yet" do
      get lessons_path

      expect(response).to have_http_status(:ok)
    end
  end
end
