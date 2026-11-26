require "rails_helper"

RSpec.describe "Public Feedbacks", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:valid_params) { { topic: "facility", message: "Soyunma odaları her zaman çok temiz, teşekkürler." } }

  def submit(params = valid_params, website: "")
    post feedback_path, params: { feedback: params, website: website }
  end

  describe "GET /geri-bildirim" do
    it "asks only for a topic and a message, and tells the visitor no name is needed" do
      get new_feedback_path

      expect(response).to have_http_status(:ok)
      fields = Nokogiri::HTML(response.body).css("form[action='#{feedback_path}'] [name^='feedback']").map { |field| field[:name] }
      expect(fields.uniq).to eq([ "feedback[topic]", "feedback[message]" ])
      expect(response.body).to include("İsim istenmez.")
    end

    it "keeps the page out of search results" do
      get new_feedback_path

      expect(response.body).to include(%(<meta name="robots" content="noindex, follow">))
    end

    it "is linked from the site footer" do
      get root_path

      expect(Nokogiri::HTML(response.body).css(%(footer a[href="#{new_feedback_path}"])).map(&:text)).to eq([ "Geri Bildirim" ])
    end
  end

  describe "POST /geri-bildirim" do
    it "stores the feedback and redirects to the thank-you page" do
      expect { submit }.to change(Feedback, :count).by(1)

      expect(response).to redirect_to(thanks_feedback_path)
      expect(Feedback.last).to have_attributes(topic: "facility", message: valid_params[:message])
    end

    it "re-renders the form with the typed message when no topic is picked" do
      expect { submit(valid_params.except(:topic)) }.not_to change(Feedback, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Konu seçilmeli", valid_params[:message])
    end

    it "pretends to accept a submission whose hidden trap field was filled in, and stores nothing" do
      expect { submit(website: "http://spam.example") }.not_to change(Feedback, :count)

      expect(response).to redirect_to(thanks_feedback_path)
    end
  end

  describe "GET /geri-bildirim/tesekkurler" do
    it "sends a visitor who has not just submitted back to the form" do
      get thanks_feedback_path

      expect(response).to redirect_to(new_feedback_path)
    end

    it "is shown once after a submission and not on a refresh" do
      submit

      get thanks_feedback_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Geri Bildiriminiz Alındı")

      get thanks_feedback_path
      expect(response).to redirect_to(new_feedback_path)
    end
  end

  describe "POST /geri-bildirim over and over" do
    it "turns the sixth submission within ten minutes away but keeps what the visitor typed" do
      5.times { submit }

      expect { submit({ topic: "classes", message: "Limit sonrası yazdığım mesaj" }) }.not_to change(Feedback, :count)

      expect(response).to have_http_status(:too_many_requests)
      expect(response.body).to include("Gönderim sınırına ulaşıldı", "Limit sonrası yazdığım mesaj")
    end

    it "lets the visitor send again once ten minutes pass, up to twenty a day" do
      4.times do
        5.times { submit }
        travel 11.minutes
      end

      expect { submit }.not_to change(Feedback, :count)
      expect(response).to have_http_status(:too_many_requests)
      expect(Feedback.count).to eq(20)
    end

    it "counts submissions without keeping the sender's IP address" do
      limited_by = nil
      subscriber = ActiveSupport::Notifications.subscribe("rate_limit.action_controller") { |*, payload| limited_by = payload[:by] }

      6.times { submit }

      expect(limited_by).to match(/\A\h{64}\z/)
      expect(limited_by).not_to include(request.remote_ip)
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end
  end
end
