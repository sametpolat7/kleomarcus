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

  describe "#email_off" do
    it "fences a block of markup off from Cloudflare's address obfuscation" do
      html = helper.email_off { helper.link_to("ayse@example.com", "mailto:ayse@example.com") }

      expect(html).to eq(%(<!--email_off--><a href="mailto:ayse@example.com">ayse@example.com</a><!--/email_off-->))
    end

    it "still escapes a bare value handed to it instead of a block" do
      expect(helper.email_off("<b>ayse@example.com")).to eq("<!--email_off-->&lt;b&gt;ayse@example.com<!--/email_off-->")
    end
  end

  describe "#admin_modal_header" do
    it "fences the subtitle off in case the record's own name holds an address" do
      html = helper.admin_modal_header("Başvuru Detayı", cancel_path: "/admin/basvurular", subtitle: "ayse@example.com")

      expect(html).to include("<!--email_off-->ayse@example.com<!--/email_off-->")
    end

    it "renders no subtitle paragraph when there is nothing to show" do
      html = helper.admin_modal_header("Başvuru Detayı", cancel_path: "/admin/basvurular")

      expect(html).not_to include("email_off")
    end
  end
end
