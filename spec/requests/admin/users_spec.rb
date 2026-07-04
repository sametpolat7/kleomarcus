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

    describe "POST /admin/kullanicilar with mismatched passwords" do
      it "returns 422 and does not create a user" do
        expect {
          post admin_users_path, params: { user: valid_params.merge(password_confirmation: "different") }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("hata oluştu")
      end
    end

    describe "PATCH /admin/kullanicilar/:id" do
      it "updates the user and redirects to the index" do
        user = create(:user, :staff)

        patch admin_user_path(user), params: { user: { role: "admin" } }

        expect(user.reload).to be_admin
        expect(response).to redirect_to(admin_users_path)
      end

      it "keeps the current password when the password fields are left blank" do
        user = create(:user, :staff)

        patch admin_user_path(user), params: {
          user: { username: "renamed_user", password: "", password_confirmation: "" }
        }

        expect(user.reload.username).to eq("renamed_user")
        expect(user.authenticate("secret123")).to be_truthy
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
end
