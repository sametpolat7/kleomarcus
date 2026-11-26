require "rails_helper"

RSpec.describe "Admin Feedback Poster", type: :request do
  let(:production_url) { "https://kleomarcus.com/geri-bildirim" }

  def qr_code_for(url)
    Object.new.extend(Admin::Feedbacks::PostersHelper).feedback_qr_code(url)
  end

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_feedbacks_poster_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as staff" do
    before { sign_in(create(:user, :staff)) }

    describe "GET /admin/geri-bildirimler/qr-afisi" do
      it "points the QR code at the live feedback form, whichever host serves the panel" do
        get admin_feedbacks_poster_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(qr_code_for(production_url))
        expect(response.body).to include("kleomarcus.com/geri-bildirim")
      end

      it "opens as a standalone sheet in the light theme, without the panel around it" do
        get admin_feedbacks_poster_path

        page = Nokogiri::HTML(response.body)
        expect(page.at_css("html")["data-theme"]).to eq("pastel")
        expect(page.css("aside")).to be_empty
        expect(page.css("[data-controller='print'] button[data-action='print#print']").map(&:text)).to eq([ "Yazdır" ])
      end

      it "is linked from the feedback list, opening in a new tab" do
        get admin_feedbacks_path

        link = Nokogiri::HTML(response.body).at_css(%(a[href="#{admin_feedbacks_poster_path}"]))
        expect(link.text.squish).to eq("QR Afişi")
        expect(link["target"]).to eq("_blank")
      end
    end
  end
end
