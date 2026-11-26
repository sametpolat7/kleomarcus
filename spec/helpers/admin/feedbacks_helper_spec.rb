require "rails_helper"

RSpec.describe Admin::FeedbacksHelper, type: :helper do
  before { helper.extend(Admin::BaseHelper) }

  describe "#feedback_topic_label" do
    it "shows the Turkish topic name in a badge coloured for that topic" do
      feedback = build(:feedback, topic: :facility)

      expect(helper.feedback_topic_label(feedback)).to have_css("span.badge.badge-info", text: "Salon ve Tesis")
    end
  end
end
