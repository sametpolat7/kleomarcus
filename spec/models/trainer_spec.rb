require "rails_helper"

RSpec.describe Trainer, type: :model do
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
