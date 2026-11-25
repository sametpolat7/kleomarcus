require "rails_helper"

RSpec.describe "Admin updates a membership plan's price", :js, type: :system do
  before do
    admin = create(:user, :admin)

    visit new_admin_session_path
    fill_in "username", with: admin.username
    fill_in "password", with: AdminAuth::PASSWORD
    click_button "Giriş Yap"
    expect(page).to have_current_path(admin_root_path)
  end

  it "groups the thousands with a dot while the price is typed" do
    create(:membership_plan, monthly_price: 2_500)
    visit admin_membership_plans_path
    click_link "Fiyatı Düzenle"
    wait_for_stimulus("numeric-input")

    fill_in "membership_plan_monthly_price", with: "15000"

    expect(find("#membership_plan_monthly_price").value).to eq("15.000")
  end
end
