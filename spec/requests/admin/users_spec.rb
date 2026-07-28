require "rails_helper"

RSpec.describe "Admin Users", type: :request do
  let(:admin) { create(:user, :admin) }

  let(:valid_params) do
    {
      username: "new_member",
      email_address: "new_member@test.local",
      role: "staff",
      password: "secret123",
      password_confirmation: "secret123"
    }
  end

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_users_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as admin" do
    before { sign_in(admin) }

    describe "GET /admin/kullanicilar" do
      it "returns 200 and lists existing users" do
        get admin_users_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(admin.username)
      end
    end

    describe "POST /admin/kullanicilar with valid params" do
      it "creates the user and redirects to the index" do
        expect {
          post admin_users_path, params: { user: valid_params }
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(admin_users_path)
      end
    end

    describe "GET /admin/kullanicilar/new" do
      it "offers only the roles that carry panel access" do
        get new_admin_user_path

        roles = Nokogiri::HTML(response.body).css("select[name='user[role]'] option").map(&:text)
        expect(roles).to contain_exactly("Yönetici", "Personel")
      end
    end

    describe "POST /admin/kullanicilar with a role the panel does not offer" do
      it "ignores the submitted role and falls back to the default" do
        post admin_users_path, params: { user: valid_params.merge(role: "athlete") }

        expect(User.find_by(username: "new_member")).to be_staff
      end
    end

    describe "POST /admin/kullanicilar with too short a password" do
      it "returns 422 and does not create a user" do
        short = "a" * (User::MINIMUM_PASSWORD_LENGTH - 1)

        expect {
          post admin_users_path, params: { user: valid_params.merge(password: short, password_confirmation: short) }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "POST /admin/kullanicilar with mismatched passwords" do
      it "returns 422 and does not create a user" do
        expect {
          post admin_users_path, params: { user: valid_params.merge(password_confirmation: "different") }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("hata oluştu")
      end
    end

    describe "GET /admin/kullanicilar/:id/edit" do
      it "renders the role as a select when the panel can assign it" do
        user = create(:user, :staff)

        get edit_admin_user_path(user)

        expect(response).to have_http_status(:ok)
        select = Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame select[name='user[role]']")
        expect(select.css("option").map { |option| [ option.text, option[:value] ] })
          .to contain_exactly([ "Yönetici", "admin" ], [ "Personel", "staff" ])
      end

      it "renders a role the panel cannot assign as a read-only badge instead of a select" do
        athlete = create(:user, :athlete)

        get edit_admin_user_path(athlete)

        expect(response).to have_http_status(:ok)
        frame = Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame")
        expect(frame.at_css("select[name='user[role]']")).to be_nil
        expect(frame.text).to include("Sporcu").and include("Bu rol panelden değiştirilemez.")
      end
    end

    describe "PATCH /admin/kullanicilar/:id" do
      it "updates the user and redirects to the index" do
        user = create(:user, :staff)

        patch admin_user_path(user), params: { user: { role: "admin" } }

        expect(user.reload).to be_admin
        expect(response).to redirect_to(admin_users_path)
      end

      it "refuses to demote a user into a role without panel access" do
        user = create(:user, :admin)

        patch admin_user_path(user), params: { user: { role: "athlete" } }

        expect(user.reload).to be_admin
      end

      it "refuses to promote an account that has no panel access to begin with" do
        athlete = create(:user, :athlete)

        patch admin_user_path(athlete), params: { user: { role: "admin" } }

        expect(athlete.reload).to be_athlete
      end

      it "keeps the current password when the password fields are left blank" do
        user = create(:user, :staff)

        patch admin_user_path(user), params: {
          user: { username: "renamed_user", password: "", password_confirmation: "" }
        }

        expect(user.reload.username).to eq("renamed_user")
        expect(user.authenticate(AdminAuth::PASSWORD)).to be_truthy
      end

      it "revokes every session the target's old password opened, keeping the admin's own" do
        victim = create(:user, :staff)
        3.times { victim.sessions.create! }
        admin_session = admin.sessions.sole

        patch admin_user_path(victim), params: {
          user: { password: "brandnewpw", password_confirmation: "brandnewpw" }
        }

        expect(victim.sessions.reload).to be_empty
        expect(Session.exists?(admin_session.id)).to be(true)
        expect(response).to redirect_to(admin_users_path)
      end

      it "leaves the target's sessions alone when only the email changes" do
        victim = create(:user, :staff)
        3.times { victim.sessions.create! }

        patch admin_user_path(victim), params: {
          user: { email_address: "yeni_adres@test.local", password: "", password_confirmation: "" }
        }

        expect(victim.reload.email_address).to eq("yeni_adres@test.local")
        expect(victim.sessions.reload.count).to eq(3)
      end

      it "keeps the admin signed in when they reset their own password" do
        patch admin_user_path(admin), params: {
          user: { password: "mybrandnew", password_confirmation: "mybrandnew" }
        }

        expect(admin.sessions.reload.count).to eq(1)

        get admin_root_path

        expect(response).to have_http_status(:ok)
      end
    end

    describe "DELETE /admin/kullanicilar/:id" do
      it "deletes another user and redirects to the index" do
        other = create(:user, :staff)

        expect {
          delete admin_user_path(other)
        }.to change(User, :count).by(-1)

        expect(response).to redirect_to(admin_users_path)
      end

      it "refuses to delete the signed-in user and shows an alert" do
        expect {
          delete admin_user_path(admin)
        }.not_to change(User, :count)

        expect(response).to redirect_to(admin_users_path)
        expect(flash[:alert]).to include("Kendi hesabınızı")
      end
    end
  end

  context "authenticated as staff" do
    let(:staff) { create(:user, :staff) }
    let(:forbidden_alert) { "Bu bölüme yalnızca yöneticiler erişebilir." }

    before { sign_in(staff) }

    describe "GET /admin/kullanicilar, /admin/kullanicilar/new and /admin/kullanicilar/:id/edit" do
      it "turns a staff member away from every read action" do
        other = create(:user, :admin)

        [ admin_users_path, new_admin_user_path, edit_admin_user_path(other) ].each do |path|
          get path

          expect(response).to redirect_to(admin_root_path)
          expect(flash[:alert]).to eq(forbidden_alert)
        end
      end
    end

    describe "POST /admin/kullanicilar" do
      it "creates no user" do
        expect {
          post admin_users_path, params: { user: valid_params }
        }.not_to change(User, :count)

        expect(response).to redirect_to(admin_root_path)
        expect(flash[:alert]).to eq(forbidden_alert)
      end
    end

    describe "PATCH /admin/kullanicilar/:id" do
      it "cannot reset an administrator's password" do
        target = create(:user, :admin)

        expect {
          patch admin_user_path(target), params: {
            user: { password: "takenoverpw", password_confirmation: "takenoverpw" }
          }
        }.not_to change { target.reload.password_digest }

        expect(response).to redirect_to(admin_root_path)
      end
    end

    describe "DELETE /admin/kullanicilar/:id" do
      it "keeps the target user" do
        target = create(:user, :admin)

        expect {
          delete admin_user_path(target)
        }.not_to change(User, :count)

        expect(User.exists?(target.id)).to be(true)
        expect(response).to redirect_to(admin_root_path)
      end
    end
  end
end
