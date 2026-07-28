require "rails_helper"

RSpec.describe Discipline, type: :model do
  describe "validations" do
    it "rejects a name that only differs from an existing one by case" do
      create(:discipline, name: "Muay Thai")

      expect(build(:discipline, name: "muay thai")).not_to be_valid
    end
  end

  describe "normalizations" do
    it "trims the surrounding whitespace off the name" do
      expect(build(:discipline, name: "  Kick Boks  ").name).to eq("Kick Boks")
    end
  end
end
