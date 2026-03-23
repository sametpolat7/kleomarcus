require "rails_helper"

RSpec.describe Public::ClubsHelper, type: :helper do
  describe "#trainers_data" do
    let(:trainers) { helper.trainers_data }

    it "returns an array of trainers" do
      expect(trainers).to be_an(Array)
    end

    it "includes all required trainer attributes" do
      trainers.each do |trainer|
        expect(trainer).to have_key(:name)
        expect(trainer).to have_key(:title)
        expect(trainer).to have_key(:image)
        expect(trainer).to have_key(:branches)
        expect(trainer).to have_key(:bio)
      end
    end

    context "trainer details" do
      it "includes Mazlum Orak as head trainer" do
        mazlum = trainers.find { |t| t[:name] == "Mazlum Orak" }
        expect(mazlum).to be_present
        expect(mazlum[:title]).to eq("Baş Antrenör")
      end
    end

    context "trainer branches" do
      it "returns branches as arrays" do
        trainers.each do |trainer|
          expect(trainer[:branches]).to be_an(Array)
        end
      end

      it "includes multiple branches for head trainer" do
        mazlum = trainers.find { |t| t[:name] == "Mazlum Orak" }
        expect(mazlum[:branches]).to include("Boks", "Kick Boks", "Muay Thai", "MMA")
      end
    end

    # context "trainer biographies" do
    #   it "provides bio text for each trainer" do
    #     trainers.each do |trainer|
    #       expect(trainer[:bio]).to be_a(String)
    #       expect(trainer[:bio]).not_to be_empty
    #     end
    #   end
    # end
  end

  describe "#schedule_days" do
    it "returns array of Turkish day names" do
      expect(helper.schedule_days).to be_an(Array)
    end

    it "returns 7 days" do
      expect(helper.schedule_days.size).to eq(7)
    end

    it "starts with Pazartesi (Monday)" do
      expect(helper.schedule_days.first).to eq("Pazartesi")
    end

    it "ends with Pazar (Sunday)" do
      expect(helper.schedule_days.last).to eq("Pazar")
    end

    it "includes all weekdays in Turkish" do
      days = helper.schedule_days
      expect(days).to eq([ "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar" ])
    end
  end

  describe "#schedule_hours" do
    let(:hours) { helper.schedule_hours }

    it "returns array of time slots" do
      expect(hours).to be_an(Array)
    end

    it "includes start and end times for each slot" do
      hours.each do |hour|
        expect(hour).to have_key(:start)
        expect(hour).to have_key(:end)
      end
    end
  end

  describe "#format_time_range" do
    it "formats time range with hyphen" do
      hour = { start: "10:00", end: "11:00" }
      expect(helper.format_time_range(hour)).to eq("10:00-11:00")
    end

    it "handles evening time slots" do
      hour = { start: "18:15", end: "19:15" }
      expect(helper.format_time_range(hour)).to eq("18:15-19:15")
    end

    it "returns string format" do
      hour = { start: "12:00", end: "13:00" }
      result = helper.format_time_range(hour)
      expect(result).to be_a(String)
    end
  end

  describe "#schedule_data" do
    let(:schedule) { helper.schedule_data }

    it "returns hash of days and schedules" do
      expect(schedule).to be_a(Hash)
    end

    it "includes all 7 days" do
      expect(schedule.keys.size).to eq(7)
    end

    it "includes Turkish day names as keys" do
      expect(schedule.keys).to include("Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar")
    end
  end

  describe "#gallery_images" do
    let(:images) { helper.gallery_images }

    it "returns an array of images" do
      expect(images).to be_an(Array)
    end

    it "includes src and alt for each image" do
      images.each do |image|
        expect(image).to have_key(:src)
        expect(image).to have_key(:alt)
      end
    end

    context "accessibility" do
      it "provides alt text for all images" do
        images.each do |image|
          expect(image[:alt]).to be_a(String)
          expect(image[:alt]).not_to be_empty
        end
      end
    end
  end
end
