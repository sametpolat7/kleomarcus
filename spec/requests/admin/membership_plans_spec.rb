require "rails_helper"

RSpec.describe "Admin Membership Plans", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_membership_plans_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as admin" do
    before { sign_in(admin) }

    describe "GET /admin/uyelik-paketleri" do
      it "lists the plans in panel order with their monthly price" do
        create(:membership_plan, name: "Özel Ders 2", monthly_price: 12_000, position: 2)
        create(:membership_plan, name: "Özel Ders 1", monthly_price: 8_000, position: 1)

        get admin_membership_plans_path

        expect(response).to have_http_status(:ok)
        rows = Nokogiri::HTML(response.body).css("table tbody tr").map { |row| row.text.squish }
        expect(rows).to match([
          a_string_including("Özel Ders 1", "₺8.000"),
          a_string_including("Özel Ders 2", "₺12.000")
        ])
      end

      it "is reachable from the sidebar" do
        get admin_root_path

        expect(Nokogiri::HTML(response.body).css(%(aside a[href="#{admin_membership_plans_path}"]))).not_to be_empty
      end
    end

    describe "GET /admin/uyelik-paketleri/:id/edit" do
      it "offers the price, and only the price, prefilled with its thousands separator" do
        plan = create(:membership_plan, monthly_price: 8_000)

        get edit_admin_membership_plan_path(plan)

        expect(response).to have_http_status(:ok)
        form = Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame form")
        expect(form.css("input[name^='membership_plan']").map { |field| [ field[:name], field[:value] ] })
          .to eq([ [ "membership_plan[monthly_price]", "8.000" ] ])
      end
    end

    describe "PATCH /admin/uyelik-paketleri/:id" do
      it "stores a price typed with a thousands separator and redirects to the index" do
        plan = create(:membership_plan, monthly_price: 8_000)

        patch admin_membership_plan_path(plan), params: { membership_plan: { monthly_price: "15.000" } }

        expect(plan.reload.monthly_price).to eq(15_000)
        expect(response).to redirect_to(admin_membership_plans_path)
        expect(flash[:notice]).to eq("Paket fiyatı güncellendi.")
      end

      it "changes nothing but the price" do
        plan = create(:membership_plan, name: "Grup Dersleri", position: 2)

        patch admin_membership_plan_path(plan), params: {
          membership_plan: { monthly_price: "2.750", name: "Başka Paket", featured: "1", position: 9 }
        }

        expect(plan.reload).to have_attributes(monthly_price: 2_750, name: "Grup Dersleri", featured: false, position: 2)
      end

      it "returns 422 with the error block and keeps the old price when the new one is zero" do
        plan = create(:membership_plan, monthly_price: 8_000)

        patch admin_membership_plan_path(plan), params: { membership_plan: { monthly_price: "0" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("hata oluştu")
        expect(plan.reload.monthly_price).to eq(8_000)
      end
    end
  end

  context "authenticated as staff" do
    let(:forbidden_alert) { "Bu bölüme yalnızca yöneticiler erişebilir." }

    before { sign_in(create(:user, :staff)) }

    describe "GET /admin/uyelik-paketleri and /admin/uyelik-paketleri/:id/edit" do
      it "turns a staff member away from the list and the form" do
        plan = create(:membership_plan)

        [ admin_membership_plans_path, edit_admin_membership_plan_path(plan) ].each do |path|
          get path

          expect(response).to redirect_to(admin_root_path)
          expect(flash[:alert]).to eq(forbidden_alert)
        end
      end

      it "keeps the pricing link out of the sidebar" do
        get admin_root_path

        expect(Nokogiri::HTML(response.body).css(%(aside a[href="#{admin_membership_plans_path}"]))).to be_empty
      end
    end

    describe "PATCH /admin/uyelik-paketleri/:id" do
      it "cannot change a price" do
        plan = create(:membership_plan, monthly_price: 8_000)

        expect {
          patch admin_membership_plan_path(plan), params: { membership_plan: { monthly_price: "1" } }
        }.not_to change { plan.reload.monthly_price }

        expect(response).to redirect_to(admin_root_path)
      end
    end
  end
end
