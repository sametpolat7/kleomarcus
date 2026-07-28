require "rails_helper"

RSpec.describe Lesson, type: :model do
  describe "validations" do
    it "requires the end time to be after the start time" do
      lesson = build(:lesson, start_time: "10:00", end_time: "09:00")

      expect(lesson).not_to be_valid
      expect(lesson.errors[:end_time]).to include("başlangıç saatinden sonra olmalıdır")
    end

    it "rejects equal start and end times" do
      lesson = build(:lesson, start_time: "10:00", end_time: "10:00")

      expect(lesson).not_to be_valid
    end

    it "rejects an identical lesson in the same day and time slot" do
      create(:lesson, name: "Gençler", day_of_week: :monday, start_time: "19:15", end_time: "20:15")
      duplicate = build(:lesson, name: "Gençler", day_of_week: :monday, start_time: "19:15", end_time: "20:15")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:base]).to include("Aynı isimle, aynı gün ve saatte ders eklenemez.")
    end

    it "allows a differently named lesson in the same slot" do
      create(:lesson, name: "Gençler", day_of_week: :monday, start_time: "19:15", end_time: "20:15")
      other = build(:lesson, name: "Yetişkinler", day_of_week: :monday, start_time: "19:15", end_time: "20:15")

      expect(other).to be_valid
    end
  end

  describe ".schedule_hours" do
    it "lists every distinct time slot once, earliest first" do
      create(:lesson, day_of_week: :monday, start_time: "19:15", end_time: "20:15")
      create(:lesson, day_of_week: :tuesday, start_time: "19:15", end_time: "20:15")
      create(:lesson, day_of_week: :monday, start_time: "09:00", end_time: "10:00")

      expect(described_class.schedule_hours).to eq([ [ "09:00", "10:00" ], [ "19:15", "20:15" ] ])
    end
  end

  describe ".schedule_kinds" do
    it "collapses each day/time slot to team when any lesson is a group lesson" do
      create(:lesson, day_of_week: :monday, start_time: "19:15", end_time: "20:15", kind: :solo)
      create(:lesson, day_of_week: :monday, start_time: "19:15", end_time: "20:15", kind: :team, name: "Grup")

      expect(described_class.schedule_kinds.dig("monday", "19:15")).to eq("team")
    end

    it "marks a slot as solo when it holds only individual lessons" do
      create(:lesson, day_of_week: :tuesday, start_time: "10:00", end_time: "11:00", kind: :solo)

      expect(described_class.schedule_kinds.dig("tuesday", "10:00")).to eq("solo")
    end
  end

  describe ".ordered" do
    it "orders by day of week, then start time" do
      monday_late = create(:lesson, day_of_week: :monday, start_time: "11:00", end_time: "12:00")
      monday_early = create(:lesson, day_of_week: :monday, start_time: "09:00", end_time: "10:00")
      sunday = create(:lesson, day_of_week: :sunday, start_time: "15:00", end_time: "16:00")

      expect(described_class.ordered).to eq([ sunday, monday_early, monday_late ])
    end
  end

  describe ".day_name" do
    it "maps the enum day to its localized name" do
      expect(described_class.day_name(:monday)).to eq(I18n.t("date.day_names")[1])
      expect(described_class.day_name(:sunday)).to eq(I18n.t("date.day_names")[0])
    end
  end

  describe ".schedule_days" do
    it "lists the days starting from Monday" do
      expect(described_class.schedule_days.first).to eq("monday")
      expect(described_class.schedule_days.last).to eq("sunday")
    end
  end

  describe "#time_range" do
    it "reads as the two clock times joined by an en dash" do
      lesson = build(:lesson, start_time: "19:15", end_time: "20:15")

      expect(lesson.time_range).to eq("19:15–20:15")
    end
  end
end
