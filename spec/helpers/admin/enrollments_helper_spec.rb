require "rails_helper"

RSpec.describe Admin::EnrollmentsHelper, type: :helper do
  before { helper.extend(Admin::BaseHelper) }

  describe "#enrollment_status_label" do
    it "shows the Turkish status name in a badge coloured for that status" do
      enrollment = build(:enrollment, status: :positive)

      expect(helper.enrollment_status_label(enrollment)).to have_css("span.badge.badge-success", text: "Olumlu")
    end
  end

  describe "#format_phone" do
    it "groups a stored mobile number into readable blocks" do
      expect(helper.format_phone("05321234567")).to eq("0532 123 45 67")
    end

    it "replaces the +90 country code with a leading zero" do
      expect(helper.format_phone("+90 532 123 45 67")).to eq("0532 123 45 67")
    end

    it "prefixes a number that was stored without its leading zero" do
      expect(helper.format_phone("5321234567")).to eq("0532 123 45 67")
    end

    it "returns the value untouched when it is not a phone number" do
      expect(helper.format_phone("123")).to eq("123")
    end
  end
end
