require "rails_helper"

RSpec.describe "Admin Sessions", type: :request do
  let(:password) { "secret123" }

  describe "GET /admin/oturum/new" do
    it "renders the unauthenticated login page" do
      get new_admin_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Giriş Yapın")
      expect(response.body).not_to include("admin-sidebar-item")
    end
  end

  describe "POST /admin/oturum" do
    it "signs in a user with panel access and redirects to the admin root" do
      admin = create(:user, :admin, password: password)

      expect do
        post admin_session_path, params: { username: admin.username, password: password }
      end.to change(admin.sessions, :count).by(1)

      expect(response).to redirect_to(admin_root_url)
    end

    it "rejects a wrong password with a Turkish error and no session" do
      admin = create(:user, :admin, password: password)

      post admin_session_path, params: { username: admin.username, password: "wrong" }

      expect(admin.sessions).to be_empty
      expect(response).to redirect_to(new_admin_session_path)
      expect(flash[:alert]).to include("kullanıcı adı")
    end
  end

  describe "DELETE /admin/oturum" do
    it "terminates the session and blocks the panel afterwards" do
      admin = create(:user, :admin, password: password)
      post admin_session_path, params: { username: admin.username, password: password }

      delete admin_session_path

      expect(response).to redirect_to(new_admin_session_path)
      expect(admin.sessions.reload).to be_empty

      get admin_root_path
      expect(response).to redirect_to(new_admin_session_path)
    end
  end
end
