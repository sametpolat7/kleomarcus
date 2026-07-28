require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "rejects a username with disallowed characters" do
      user = build(:user, username: "Has Spaces!")

      expect(user).not_to be_valid
      expect(user.errors[:username]).to be_present
    end

    it "rejects a duplicate username regardless of case" do
      create(:user, username: "coach")
      duplicate = build(:user, username: "COACH")

      expect(duplicate).not_to be_valid
    end

    it "rejects a password shorter than the minimum" do
      short = "a" * (described_class::MINIMUM_PASSWORD_LENGTH - 1)
      user = build(:user, password: short, password_confirmation: short)

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end

  describe "normalization" do
    it "downcases and strips the username and email" do
      user = create(:user, username: "  ILKAY_01  ", email_address: "  Ilkay@Test.LOCAL ")

      expect(user.username).to eq("ilkay_01")
      expect(user.email_address).to eq("ilkay@test.local")
    end
  end

  describe "#panel_access?" do
    it "is true for admins and staff" do
      expect(build(:user, :admin).panel_access?).to be(true)
      expect(build(:user, :staff).panel_access?).to be(true)
    end

    it "is false for athletes" do
      expect(build(:user, :athlete).panel_access?).to be(false)
    end
  end
end
