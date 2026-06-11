require "rails_helper"

RSpec.describe Testimonial, type: :model do
  describe "validations" do
    it "is valid with the factory defaults" do
      expect(build(:testimonial)).to be_valid
    end

    it "requires an author name and content" do
      testimonial = build(:testimonial, author_name: "", content: "")

      expect(testimonial).not_to be_valid
      expect(testimonial.errors[:author_name]).to be_present
      expect(testimonial.errors[:content]).to be_present
    end

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

      expect(described_class.ordered).to eq([newer, older])
    end
  end
end
