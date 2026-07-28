require "rails_helper"

RSpec.describe Testimonial, type: :model do
  describe "validations" do
    it "only accepts a rating between 1 and 5" do
      expect(build(:testimonial, rating: 0)).not_to be_valid
      expect(build(:testimonial, rating: 6)).not_to be_valid
      expect(build(:testimonial, rating: 3)).to be_valid
    end
  end

  describe ".ordered" do
    it "returns the newest testimonials first" do
      older = create(:testimonial, created_at: 2.days.ago)
      newer = create(:testimonial, created_at: 1.hour.ago)

      expect(described_class.ordered).to eq([ newer, older ])
    end
  end

  describe "#initials" do
    it "takes the first letter of the first two names" do
      expect(build(:testimonial, author_name: "ayşe yılmaz").initials).to eq("A.Y.")
    end

    it "ignores everything past the second name" do
      expect(build(:testimonial, author_name: "Ali Vural Öz").initials).to eq("A.V.")
    end

    it "falls back to a question mark when the name holds no letters" do
      expect(build(:testimonial, author_name: "-- 42 --").initials).to eq("?")
    end
  end
end
