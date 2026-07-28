require "rails_helper"

RSpec.describe "Error pages", type: :request do
  describe "a path that matches no route" do
    it "renders the branded 404 page with the site chrome around it" do
      with_error_pages { get "/boyle-bir-sayfa-yok" }

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("<title>404 · Sayfa Bulunamadı | Kleomarcus</title>")
      expect(response.body).to include("Sayfa Bulunamadı")
      expect(response.body).to include("KLEOMARCUS")
    end

    it "renders without opening a session or emitting a CSRF token" do
      with_error_pages { get "/boyle-bir-sayfa-yok" }

      expect(response.headers["Set-Cookie"]).to be_nil
      expect(response.body).not_to include("csrf-token")
      expect(response.headers["Cache-Control"]).to eq("no-store")
    end

    %w[pdf xml csv txt png].each do |extension|
      it "renders the dynamic HTML page for a missing path ending in .#{extension}" do
        with_error_pages { get "/boyle-bir-sayfa-yok.#{extension}" }

        expect(response).to have_http_status(:not_found)
        expect(response.media_type).to eq("text/html")
        expect(response.body).to include("Sayfa Bulunamadı")
        expect(response.body).to include("Hızlı Bağlantılar")
      end
    end

    it "answers a JSON request with JSON instead of the HTML page" do
      with_error_pages { get "/boyle-bir-sayfa-yok", headers: { "Accept" => "application/json" } }

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["status"]).to eq(404)
      expect(response.parsed_body["error"]).to eq("Sayfa Bulunamadı")
    end

    it "answers a .json path with JSON even though no Accept header asks for it" do
      with_error_pages { get "/boyle-bir-sayfa-yok.json" }

      expect(response).to have_http_status(:not_found)
      expect(response.media_type).to eq("application/json")
      expect(response.parsed_body["error"]).to eq("Sayfa Bulunamadı")
    end

    it "answers HEAD with the status and an empty body" do
      with_error_pages { head "/boyle-bir-sayfa-yok" }

      expect(response).to have_http_status(:not_found)
      expect(response.body).to be_empty
    end
  end

  describe "a real route asked for in a format the app does not render" do
    it "renders the branded 406 page with an actual body" do
      with_error_pages { get lessons_path(format: :pdf) }

      expect(response).to have_http_status(:not_acceptable)
      expect(response.media_type).to eq("text/html")
      expect(response.body).to include("İçerik Görüntülenemiyor")
      expect(response.body).to include("Hızlı Bağlantılar")
    end
  end

  describe "a malformed query string" do
    it "renders the branded 400 page rather than falling through to the static one" do
      with_error_pages { get "/?filtre[]=1&filtre[a]=2" }

      expect(response).to have_http_status(:bad_request)
      expect(response.body).to include("Geçersiz İstek")
    end
  end

  describe "a failure while the database is unreachable" do
    it "still renders the branded 500 page with an error reference" do
      allow(Trainer).to receive(:ordered).and_raise(ActiveRecord::ConnectionNotEstablished)

      with_error_pages { get trainers_path }

      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include("Beklenmeyen Bir Hata Oluştu")
      expect(response.body).to include("Hata referansı")
    end
  end

  describe "when the branded page itself cannot render" do
    it "falls back to the branded static page in public/" do
      allow(ErrorsController).to receive(:action).and_raise(RuntimeError, "asset manifest missing")

      with_error_pages { get "/boyle-bir-sayfa-yok" }

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Sayfa Bulunamadı")
      expect(response.body).not_to include("Hızlı Bağlantılar")
    end
  end

  describe "an admin modal request for a row that no longer exists" do
    let(:admin) { create(:user, :admin) }

    before { sign_in(admin) }

    it "answers with a matching turbo frame so the dialog has something to show" do
      with_error_pages do
        get edit_admin_trainer_path(id: 0), headers: { "Turbo-Frame" => "admin_modal_frame" }
      end

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include(%(<turbo-frame id="admin_modal_frame">))
      expect(response.body).to include("Sayfa Bulunamadı")
    end

    it "still answers with the frame when the modal URL carries a format" do
      with_error_pages do
        get edit_admin_trainer_path(id: 0, format: :pdf), headers: { "Turbo-Frame" => "admin_modal_frame" }
      end

      expect(response).to have_http_status(:not_found)
      expect(response.media_type).to eq("text/html")
      expect(response.body).to include(%(<turbo-frame id="admin_modal_frame">))
      expect(response.body).to include("Sayfa Bulunamadı")
    end

    it "leaves the page chrome out of the frame response" do
      with_error_pages do
        get edit_admin_trainer_path(id: 0), headers: { "Turbo-Frame" => "admin_modal_frame" }
      end

      expect(response.body).not_to include("<!DOCTYPE html>")
      expect(response.body).not_to include("KLEOMARCUS")
    end
  end
end
