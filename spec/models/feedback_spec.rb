require "rails_helper"

RSpec.describe Feedback, type: :model do
  describe "topic" do
    it "asks for a topic in plain Turkish when none or an unknown one is sent" do
      without_topic = build(:feedback, topic: nil)
      unknown_topic = build(:feedback, topic: "hacked")

      [ without_topic, unknown_topic ].each(&:validate)

      expect(without_topic.errors[:topic]).to eq([ "seçilmeli" ])
      expect(unknown_topic.errors[:topic]).to eq([ "seçilmeli" ])
    end
  end

  describe "message" do
    it "accepts from 10 up to 1000 characters" do
      expect(build(:feedback, message: "a" * 9)).not_to be_valid
      expect(build(:feedback, message: "a" * 10)).to be_valid
      expect(build(:feedback, message: "a" * 1000)).to be_valid
      expect(build(:feedback, message: "a" * 1001)).not_to be_valid
    end

    it "counts a line break as one character, as the form's maxlength does" do
      feedback = build(:feedback, message: "#{"a" * 499}\r\n#{"b" * 500}")

      expect(feedback).to be_valid
      expect(feedback.message).to eq("#{"a" * 499}\n#{"b" * 500}")
    end

    it "does not count surrounding whitespace towards the minimum" do
      feedback = build(:feedback, message: "   kısa   ")

      expect(feedback).not_to be_valid
    end

    it "reports a blank message once, not as both missing and too short" do
      feedback = build(:feedback, message: "     ")

      feedback.validate

      expect(feedback.errors[:message]).to eq([ "doldurulmalı" ])
    end
  end
end
