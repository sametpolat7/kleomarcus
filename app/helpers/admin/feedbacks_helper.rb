module Admin::FeedbacksHelper
  FEEDBACK_TOPIC_VARIANTS = {
    "trainers" => :primary,
    "facility" => :info,
    "classes" => :success,
    "other" => :neutral
  }.freeze

  def feedback_topic_label(feedback)
    badge(Feedback.enum_label(:topic, feedback.topic), variant: FEEDBACK_TOPIC_VARIANTS[feedback.topic])
  end
end
