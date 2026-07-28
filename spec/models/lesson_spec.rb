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

    it "rejects a day outside the ones the panel offers instead of raising" do
      lesson = build(:lesson)

      expect { lesson.day_of_week = "notaday" }.not_to raise_error

      expect(lesson).not_to be_valid
      expect(lesson.errors[:day_of_week]).to include("kabul edilen bir kelime değil")
    end

    it "rejects a numeric day, including the enum's own integer form" do
      out_of_range = build(:lesson)
      integer_form = build(:lesson)

      expect { out_of_range.day_of_week = "9" }.not_to raise_error
      expect { integer_form.day_of_week = "1" }.not_to raise_error

      expect(out_of_range).not_to be_valid
      expect(out_of_range.errors[:day_of_week]).to be_present
      expect(integer_form).not_to be_valid
      expect(integer_form.errors[:day_of_week]).to be_present
      expect(integer_form.day_of_week).to eq("1")
    end

    it "rejects a kind outside the ones the panel offers instead of raising" do
      lesson = build(:lesson)

      expect { lesson.kind = "hybrid" }.not_to raise_error

      expect(lesson).not_to be_valid
      expect(lesson.errors[:kind]).to include("kabul edilen bir kelime değil")
    end

    it "asks for a kind instead of letting the blank prompt reach the not-null column" do
      lesson = build(:lesson, kind: nil)

      expect(lesson).not_to be_valid
      expect(lesson.errors[:kind]).to eq([ "doldurulmalı" ])
      expect { lesson.save }.not_to change(described_class, :count)
    end
  end

  describe ".schedule_hours" do
    it "lists every distinct time slot once, earliest first" do
      create(:lesson, day_of_week: :monday, start_time: "19:15", end_time: "20:15")
      create(:lesson, day_of_week: :tuesday, start_time: "19:15", end_time: "20:15")
      create(:lesson, day_of_week: :monday, start_time: "09:00", end_time: "10:00")

      expect(described_class.schedule_hours).to eq([ [ "09:00", "10:00" ], [ "19:15", "20:15" ] ])
    end

    it "collapses lessons that share a start time into the single row the grid draws" do
      create(:lesson, name: "Gençler", day_of_week: :monday, start_time: "18:15", end_time: "19:15")
      create(:lesson, name: "Yetişkinler", day_of_week: :monday, start_time: "18:15", end_time: "20:00", kind: :team)

      expect(described_class.schedule_hours).to eq([ [ "18:15", "20:00" ] ])
      expect(described_class.schedule.dig("monday", "18:15").size).to eq(2)
      expect(described_class.schedule_kinds.dig("monday", "18:15")).to eq("team")
    end

    it "lists the start times in order and keys them the way the grid does" do
      create(:lesson, day_of_week: :monday, start_time: "18:15", end_time: "19:15")
      create(:lesson, day_of_week: :tuesday, start_time: "09:00", end_time: "10:00")
      create(:lesson, day_of_week: :monday, start_time: "12:30", end_time: "13:30")

      hours = described_class.schedule_hours

      expect(hours.map(&:first)).to eq([ "09:00", "12:30", "18:15" ])
      expect(described_class.schedule.keys).to contain_exactly("monday", "tuesday")
      expect(described_class.schedule.values.flat_map(&:keys).uniq.sort).to eq(hours.map(&:first))
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
