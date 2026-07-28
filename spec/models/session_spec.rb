require "rails_helper"

RSpec.describe Session, type: :model do
  describe "before_validation :set_expiration" do
    it "stamps a new session so it lives for a week" do
      session = create(:session)

      expect(session.expires_at).to be_within(1.minute).of(1.week.from_now)
      expect(session).not_to be_expired
    end

    it "leaves an explicitly given expiry alone" do
      expires_at = 1.hour.from_now.change(usec: 0)

      session = create(:session, expires_at: expires_at)

      expect(session.expires_at).to eq(expires_at)
    end
  end

  describe "#expired?" do
    it "is true once the expiry has passed" do
      expect(create(:session, :expired)).to be_expired
    end

    it "is true for a session left over from before expiries were recorded" do
      session = create(:session)

      session.update_column(:expires_at, nil)

      expect(session.reload).to be_expired
    end
  end

  describe ".expired" do
    it "collects the passed and the never-stamped sessions only" do
      live = create(:session)
      passed = create(:session, :expired)
      unstamped = create(:session)
      unstamped.update_column(:expires_at, nil)

      expect(described_class.expired).to contain_exactly(passed, unstamped)
      expect(described_class.expired).not_to include(live)
    end
  end
end
