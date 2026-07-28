require "rails_helper"

RSpec.describe "Admin Sessions", type: :request do
  let(:password) { AdminAuth::PASSWORD }

  describe "GET /admin/session/new" do
    it "renders the unauthenticated login page" do
      get new_admin_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Giriş Yapın")
      expect(response.body).not_to include("Çıkış Yap")
    end
  end

  describe "POST /admin/session" do
    it "signs in a user with panel access and redirects to the admin root" do
      admin = create(:user, :admin)

      expect do
        post admin_session_path, params: { username: admin.username, password: password }
      end.to change(admin.sessions, :count).by(1)

      expect(response).to redirect_to(admin_root_url)
    end

    it "gives the session cookie the session's own expiry" do
      admin = create(:user, :admin)

      post admin_session_path, params: { username: admin.username, password: password }

      expires = Array(response.headers["set-cookie"]).join("\n")[/session_id=.*?expires=([^;]+)/i, 1]
      expect(Time.parse(expires)).to be_within(1.minute).of(admin.sessions.sole.expires_at)
    end

    it "refuses an athlete, who has no panel access" do
      athlete = create(:user, :athlete)

      post admin_session_path, params: { username: athlete.username, password: password }

      expect(athlete.sessions).to be_empty
      expect(response).to redirect_to(new_admin_session_path)
    end

    it "clears the signing-in user's stale sessions" do
      admin = create(:user, :admin)
      stale = admin.sessions.create!(expires_at: 1.minute.ago)

      post admin_session_path, params: { username: admin.username, password: password }

      expect(Session.exists?(stale.id)).to be(false)
      expect(admin.sessions.reload.count).to eq(1)
    end

    it "rejects a wrong password with a Turkish error and no session" do
      admin = create(:user, :admin)

      post admin_session_path, params: { username: admin.username, password: "wrong" }

      expect(admin.sessions).to be_empty
      expect(response).to redirect_to(new_admin_session_path)
      expect(flash[:alert]).to include("kullanıcı adı")
    end
  end

  describe "DELETE /admin/session" do
    it "terminates the session and blocks the panel afterwards" do
      admin = create(:user, :admin)
      post admin_session_path, params: { username: admin.username, password: password }

      delete admin_session_path

      expect(response).to redirect_to(new_admin_session_path)
      expect(admin.sessions.reload).to be_empty

      get admin_root_path
      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "POST /admin/session over and over" do
    it "stops taking guesses from the same address after ten attempts" do
      admin = create(:user, :admin)

      10.times { post admin_session_path, params: { username: admin.username, password: "wrong" } }
      post admin_session_path, params: { username: admin.username, password: password }

      expect(admin.sessions).to be_empty
      expect(response).to redirect_to(new_admin_session_path)
      expect(flash[:alert]).to include("daha sonra tekrar deneyin")
    end
  end

  describe "an expired session" do
    it "loses panel access and is dropped from the database" do
      admin = create(:user, :admin)
      post admin_session_path, params: { username: admin.username, password: password }

      admin.sessions.sole.update_column(:expires_at, 1.minute.ago)

      get admin_root_path

      expect(response).to redirect_to(new_admin_session_path)
      expect(admin.sessions.reload).to be_empty
    end
  end
end
