require "rails_helper"

RSpec.describe "Trainers Page", type: :system do
  it "loads successfully" do
    visit trainers_club_path
    expect(page).to have_http_status(:success)
  end

  describe "trainer modals", :js do
    it "opens modal when trainer card is clicked" do
      visit trainers_club_path
      first(".cursor-pointer[onclick*='trainer_modal']").click
      expect(page).to have_selector("dialog.modal[open]", visible: true)
    end

    it "closes modal when close button is clicked" do
      visit trainers_club_path
      first(".cursor-pointer[onclick*='trainer_modal']").click
      within("dialog.modal[open]") do
        find("button.btn-circle").click
      end
      expect(page).not_to have_selector("dialog.modal[open]", visible: true)
    end
  end
end
