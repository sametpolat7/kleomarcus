class Admin::FeedbacksController < Admin::BaseController
  def index
    @topic = params[:topic].presence_in(Feedback.topics.keys)

    scope = Feedback.recent
    scope = scope.where(topic: @topic) if @topic
    @pagy, @feedbacks = pagy(scope)
  end
end
