require "rails_helper"

RSpec.describe Trainer, type: :model do
  describe "normalization" do
    it "strips the name and title without recasing them" do
      trainer = create(:trainer, name: "  Mehmet Demir  ", title: " MMA Antrenörü ")

      expect(trainer.name).to eq("Mehmet Demir")
      expect(trainer.title).to eq("MMA Antrenörü")
    end

    it "leaves an operator's casing alone, acronyms included" do
      trainer = create(:trainer, name: "mehmet demir", title: "Kick Boks / MMA")

      expect(trainer.name).to eq("mehmet demir")
      expect(trainer.title).to eq("Kick Boks / MMA")
    end
  end

  describe "position assignment" do
    it "appends new trainers to the end by default" do
      first = create(:trainer)
      second = create(:trainer)

      expect(second.position).to eq(first.position + 1)
    end

    it "shifts everyone at or after an explicit position down by one" do
      create(:trainer, name: "Ayşe")
      create(:trainer, name: "Burak")

      create(:trainer, name: "Cem", position: 1)

      expect(described_class.order(:position).pluck(:name, :position))
        .to eq([ [ "Cem", 1 ], [ "Ayşe", 2 ], [ "Burak", 3 ] ])
    end

    it "slides the rows it passes down when a trainer moves up the list" do
      create(:trainer, name: "Ayşe")
      create(:trainer, name: "Burak")
      cem = create(:trainer, name: "Cem")

      cem.update!(position: 1)

      expect(described_class.order(:position).pluck(:name, :position))
        .to eq([ [ "Cem", 1 ], [ "Ayşe", 2 ], [ "Burak", 3 ] ])
    end

    it "lands on the requested rank when a trainer moves down the list" do
      ayse = create(:trainer, name: "Ayşe")
      create(:trainer, name: "Burak")
      create(:trainer, name: "Cem")

      ayse.update!(position: 3)

      expect(described_class.order(:position).pluck(:name, :position))
        .to eq([ [ "Burak", 1 ], [ "Cem", 2 ], [ "Ayşe", 3 ] ])
    end

    it "leaves the ranking alone when an update does not move the trainer" do
      create(:trainer, name: "Ayşe")
      burak = create(:trainer, name: "Burak")
      create(:trainer, name: "Cem")

      burak.update!(title: "Kıdemli Antrenör", position: burak.position)

      expect(described_class.order(:position).pluck(:name, :position))
        .to eq([ [ "Ayşe", 1 ], [ "Burak", 2 ], [ "Cem", 3 ] ])
    end
  end

  describe "position validation" do
    it "accepts the position handed out on create" do
      trainer = build(:trainer, position: nil)

      expect(trainer).to be_valid
      expect(trainer.position).to eq(1)
    end

    it "rejects a rank below the first one" do
      trainer = build(:trainer, position: 0)

      expect(trainer).not_to be_valid
      expect(trainer.errors[:position]).to be_present
    end

    it "rejects a position that is not a number, since it casts to zero" do
      trainer = build(:trainer, position: "başa")

      expect(trainer.position).to eq(0)
      expect(trainer).not_to be_valid
    end

    it "rejects a blank position on a trainer that already holds one" do
      trainer = create(:trainer)

      expect(trainer.update(position: nil)).to be(false)
      expect(trainer.reload.position).to eq(1)
    end
  end

  describe "photo validation" do
    # A 1x1 PNG, small enough to keep inline.
    let(:png) { Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8AAAAMBAQAY3Y2wAAAAAElFTkSuQmCC") }

    it "accepts a PNG upload" do
      trainer = build(:trainer)
      trainer.photo.attach(io: StringIO.new(png), filename: "egitmen.png", content_type: "image/png")

      expect(trainer).to be_valid
    end

    it "rejects an upload that is not a JPEG, PNG or WebP" do
      trainer = build(:trainer)
      trainer.photo.attach(io: StringIO.new("%PDF-1.4"), filename: "egitmen.pdf", content_type: "application/pdf")

      expect(trainer).not_to be_valid
      expect(trainer.errors[:photo]).to include("JPEG, PNG veya WebP olmalıdır")
    end

    it "rejects a photo over the 5 MB limit" do
      trainer = build(:trainer)
      oversized = StringIO.new("0" * (described_class::PHOTO_MAX_SIZE + 1))
      trainer.photo.attach(io: oversized, filename: "egitmen.png", content_type: "image/png")

      expect(trainer).not_to be_valid
      expect(trainer.errors[:photo]).to include("en fazla 5 MB olabilir")
    end

    it "accepts a trainer with no photo at all" do
      expect(build(:trainer)).to be_valid
    end
  end

  describe "destruction" do
    it "keeps the lessons of a deleted trainer and leaves them unassigned" do
      trainer = create(:trainer)
      lesson = create(:lesson, trainer: trainer)

      trainer.destroy

      expect(lesson.reload.trainer_id).to be_nil
    end

    it "takes the trainer's disciplines down with it" do
      trainer = create(:trainer, disciplines: [ create(:discipline) ])

      expect { trainer.destroy }.to change(TrainerDiscipline, :count).by(-1)
    end
  end
end
