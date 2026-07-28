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

    it "carries the modal frame, empty, so a modal fetched without a session can recover" do
      get new_admin_session_path

      frame = Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame")
      expect(frame).to be_present
      expect(frame.text).to be_blank
    end

    it "sends a signed-in user to the panel instead of the form" do
      sign_in(create(:user, :admin))

      get new_admin_session_path

      expect(response).to redirect_to(admin_root_path)
    end

    it "still renders the form for a session that has lost panel access" do
      user = create(:user, :staff)
      sign_in(user)
      user.update_column(:role, User.roles[:athlete])

      get new_admin_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Giriş Yapın")
      expect(user.sessions.reload).to be_present
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

    it "opens no second session when someone already signed in submits the form again" do
      admin = create(:user, :admin)
      sign_in(admin)

      expect do
        post admin_session_path, params: { username: admin.username, password: password }
      end.not_to change(admin.sessions, :count)

      expect(response).to redirect_to(admin_root_path)
    end
  end

  describe "POST /admin/session with credentials the form could not have sent" do
    {
      "no params at all" => {},
      "only a username" => { username: "kleomarcus" },
      "an array where the password belongs" => { username: "kleomarcus", password: %w[a b] },
      "both fields blank" => { username: "", password: "" }
    }.each do |description, params|
      it "redirects back to the login page given #{description}" do
        post admin_session_path, params: params

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_admin_session_path)
        expect(flash[:alert]).to include("kullanıcı adı")
        expect(Session.count).to be_zero
      end
    end
  end

  describe "returning to the page that demanded a login" do
    it "hands the operator the deep page they were turned away from" do
      trainer = create(:trainer)

      get edit_admin_trainer_path(trainer)
      expect(response).to redirect_to(new_admin_session_path)

      sign_in(create(:user, :admin))

      expect(response).to redirect_to(edit_admin_trainer_url(trainer))
    end

    it "does not replay a url that answers to no GET route" do
      other = create(:user, :staff)

      delete admin_user_path(other)
      expect(response).to redirect_to(new_admin_session_path)
      expect(User.exists?(other.id)).to be(true)

      sign_in(create(:user, :admin))

      expect(response).to redirect_to(admin_root_url)
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

    it "leaves a modal fetch on a login page that still carries the modal frame" do
      admin = create(:user, :admin)
      sign_in(admin)
      admin.sessions.sole.update_column(:expires_at, 1.minute.ago)

      get new_admin_trainer_path, headers: { "Turbo-Frame" => "admin_modal_frame" }
      expect(response).to redirect_to(new_admin_session_path)

      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame")).to be_present
    end
  end
end
