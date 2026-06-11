require "rails_helper"

RSpec.describe Trainer, type: :model do
  describe "validations" do
    it "is valid with the factory defaults" do
      expect(build(:trainer)).to be_valid
    end

    it "requires a name and a title" do
      trainer = build(:trainer, name: "", title: "")

      expect(trainer).not_to be_valid
      expect(trainer.errors[:name]).to be_present
      expect(trainer.errors[:title]).to be_present
    end
  end

  describe "normalization" do
    it "titleizes the name and title" do
      trainer = create(:trainer, name: "mehmet demir", title: "baş antrenör")

      expect(trainer.name).to eq("Mehmet Demir")
      expect(trainer.title).to eq("Baş Antrenör")
    end
  end

  describe "position assignment" do
    it "appends new trainers to the end by default" do
      first = create(:trainer)
      second = create(:trainer)

      expect(second.position).to eq(first.position + 1)
    end

    it "shifts existing trainers down when an explicit position is taken" do
      first = create(:trainer)
      inserted = create(:trainer, position: first.position)

      expect(inserted.position).to eq(first.reload.position - 1)
    end
  end
end
