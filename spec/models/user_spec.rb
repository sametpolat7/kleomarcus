require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with the factory defaults" do
      expect(build(:user)).to be_valid
    end

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
  end

  describe "normalization" do
    it "downcases and strips the username and email" do
      user = create(:user, username: "  COACH_01  ", email_address: "  Coach@Test.LOCAL ")

      expect(user.username).to eq("coach_01")
      expect(user.email_address).to eq("coach@test.local")
    end
  end

  describe "#panel_access?" do
    it "is true for admins and staff" do
      expect(build(:user, :admin).panel_access?).to be(true)
      expect(build(:user, :staff).panel_access?).to be(true)
    end
  end
end
