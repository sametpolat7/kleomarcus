require "rails_helper"

RSpec.describe Admin::BaseHelper, type: :helper do
  describe "#role_label" do
    it "shows the Turkish role name in a badge coloured for that role" do
      expect(helper.role_label(build(:user, :admin))).to have_css("span.badge.badge-primary", text: "Yönetici")
    end

    it "colours a role the panel cannot hand out too" do
      expect(helper.role_label(build(:user, :athlete))).to have_css("span.badge.badge-neutral", text: "Sporcu")
    end
  end

  describe "#format_date" do
    it "writes the date out with its Turkish month name" do
      expect(helper.format_date(Date.new(2026, 3, 14))).to eq("14 Mart 2026")
    end

    it "shows a dash instead of a blank date" do
      expect(helper.format_date(nil)).to eq("—")
    end
  end
end
