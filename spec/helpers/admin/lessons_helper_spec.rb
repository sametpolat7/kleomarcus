require "rails_helper"

RSpec.describe Admin::LessonsHelper, type: :helper do
  before { helper.extend(Admin::BaseHelper) }

  describe "#lesson_kind_label" do
    it "shows the Turkish name of a group lesson in a highlighted badge" do
      lesson = build(:lesson, :team)

      expect(helper.lesson_kind_label(lesson)).to have_css("span.badge.badge-primary", text: "Grup Dersi")
    end

    it "shows a one-to-one lesson in a plain badge" do
      lesson = build(:lesson, kind: :solo)

      expect(helper.lesson_kind_label(lesson)).to have_css("span.badge.badge-neutral", text: "Özel Ders")
    end
  end
end
