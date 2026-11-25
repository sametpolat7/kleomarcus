require "rails_helper"

RSpec.describe MembershipPlan, type: :model do
  describe "#monthly_price=" do
    it "reads the thousands separator the admin form displays" do
      plan = build(:membership_plan, monthly_price: " 12.500 ")

      expect(plan.monthly_price).to eq(12_500)
    end

    it "rejects a decimal amount instead of silently truncating it" do
      plan = build(:membership_plan, monthly_price: "8,5")

      expect(plan).not_to be_valid
      expect(plan.errors[:monthly_price]).to be_present
    end
  end

  describe "price range" do
    it "accepts from 1 up to 999.999 lira a month" do
      expect(build(:membership_plan, monthly_price: 0)).not_to be_valid
      expect(build(:membership_plan, monthly_price: 1_000_000)).not_to be_valid
      expect(build(:membership_plan, monthly_price: 999_999)).to be_valid
    end
  end

  describe "#formatted_monthly_price" do
    it "groups the thousands with a dot, in a form the writer reads back unchanged" do
      plan = build(:membership_plan, monthly_price: 12_000)

      formatted = plan.formatted_monthly_price
      plan.monthly_price = formatted

      expect(formatted).to eq("12.000")
      expect(plan.monthly_price).to eq(12_000)
    end
  end
end
