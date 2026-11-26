require "rails_helper"

RSpec.describe "Admin Feedbacks", type: :request do
  def rows
    Nokogiri::HTML(response.body).css("table tbody tr").map { |row| row.text.squish }
  end

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_feedbacks_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as staff" do
    before { sign_in(create(:user, :staff)) }

    describe "GET /admin/geri-bildirimler" do
      it "lists every feedback newest first, dated by day without the time it was sent" do
        create(:feedback, topic: :trainers, message: "Antrenörümüz çok ilgili.", created_at: Time.zone.local(2026, 11, 20, 18, 45))
        create(:feedback, topic: :classes, message: "Akşam derslerine bir saat eklenebilir.", created_at: Time.zone.local(2026, 11, 25, 9, 30))

        get admin_feedbacks_path

        expect(response).to have_http_status(:ok)
        expect(rows).to match([
          a_string_including("Dersler", "Akşam derslerine bir saat eklenebilir.", "25 Kasım 2026"),
          a_string_including("Antrenörler", "Antrenörümüz çok ilgili.", "20 Kasım 2026")
        ])
        expect(response.body).not_to include("09:30", "18:45")
      end

      it "fences an address the visitor typed so Cloudflare does not obfuscate it" do
        create(:feedback, message: "Bana ali@example.com adresinden ulaşabilirsiniz.")

        get admin_feedbacks_path

        cell = Nokogiri::HTML(response.body).at_css("table tbody tr td p")
        expect(cell.inner_html).to start_with("<!--email_off-->").and end_with("<!--/email_off-->")
      end

      it "narrows the list to a single topic" do
        create(:feedback, topic: :facility, message: "Duşlar biraz daha sıcak olabilir.")
        create(:feedback, topic: :other, message: "Otopark girişine tabela iyi olurdu.")

        get admin_feedbacks_path(topic: "facility")

        expect(rows).to match([ a_string_including("Salon ve Tesis", "Duşlar biraz daha sıcak olabilir.") ])
      end

      it "is reachable from the sidebar" do
        get admin_root_path

        expect(Nokogiri::HTML(response.body).css(%(aside a[href="#{admin_feedbacks_path}"]))).not_to be_empty
      end
    end

    describe "DELETE /admin/geri-bildirimler/:id" do
      it "is not offered: feedback stays on record" do
        feedback = create(:feedback)

        expect { delete "/admin/geri-bildirimler/#{feedback.id}" }.not_to change(Feedback, :count)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
