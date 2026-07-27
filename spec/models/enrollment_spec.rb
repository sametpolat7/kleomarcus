require "rails_helper"

RSpec.describe Enrollment, type: :model do
  describe "validations" do
    it "is valid with nothing but a name, phone and age" do
      expect(build(:enrollment)).to be_valid
    end

    it "accepts a mobile number written with +90, with a leading zero, or with neither" do
      expect(build(:enrollment, phone: "+905321234567")).to be_valid
      expect(build(:enrollment, phone: "05321234567")).to be_valid
      expect(build(:enrollment, phone: "5321234567")).to be_valid
    end

    it "rejects a landline number" do
      enrollment = build(:enrollment, phone: "02861234567")

      expect(enrollment).not_to be_valid
      expect(enrollment.errors[:phone]).to be_present
    end

    it "rejects an age outside the 3–75 range the club teaches" do
      expect(build(:enrollment, age: 2)).not_to be_valid
      expect(build(:enrollment, age: 76)).not_to be_valid
      expect(build(:enrollment, age: 3)).to be_valid
      expect(build(:enrollment, age: 75)).to be_valid
    end

    it "rejects an unchecked KVKK consent box" do
      enrollment = build(:enrollment, :consented, kvkk_consent: "0")

      expect(enrollment).not_to be_valid
      expect(enrollment.errors[:kvkk_consent]).to be_present
    end

    it "rejects an unchecked information consent box" do
      enrollment = build(:enrollment, :consented, info_consent: "0")

      expect(enrollment).not_to be_valid
      expect(enrollment.errors[:info_consent]).to be_present
    end
  end

  describe "normalizations" do
    it "strips the formatting characters out of a phone number" do
      expect(build(:enrollment, phone: "0532 123-45.67").phone).to eq("05321234567")
    end

    it "title-cases the full name without dropping Turkish characters" do
      expect(build(:enrollment, full_name: "şule ÇAĞLAR").full_name).to eq("Şule Çağlar")
    end

    it "trims and downcases the email address" do
      expect(build(:enrollment, email: " Ayse@Example.COM ").email).to eq("ayse@example.com")
    end
  end

  describe "before_save :stamp_kvkk_acceptance" do
    it "records the moment the KVKK notice was accepted" do
      enrollment = create(:enrollment, :consented)

      expect(enrollment.kvkk_accepted_at).to be_present
    end

    it "leaves the acceptance time blank when no consent was given" do
      enrollment = create(:enrollment)

      expect(enrollment.kvkk_accepted_at).to be_nil
    end

    it "keeps the original acceptance time instead of re-stamping it on every save" do
      accepted_at = 3.days.ago.change(usec: 0)
      enrollment = create(:enrollment, :consented, kvkk_accepted_at: accepted_at)

      enrollment.update!(status: :called)

      expect(enrollment.reload.kvkk_accepted_at).to eq(accepted_at)
    end
  end

  describe ".recent" do
    it "puts the newest application first" do
      older = create(:enrollment, created_at: 2.days.ago)
      newest = create(:enrollment, created_at: 1.hour.ago)

      expect(described_class.recent).to eq([ newest, older ])
    end
  end
end
