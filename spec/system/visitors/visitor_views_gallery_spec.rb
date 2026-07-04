require "rails_helper"

RSpec.describe "Gallery Page", type: :system do
  it "loads successfully" do
    visit gallery_path
    expect(page).to have_http_status(:success)
  end

  describe "gallery lightbox", :js do
    it "opens lightbox when gallery item is clicked" do
      visit gallery_path
      first("[data-gallery-target='item']").click
      expect(page).to have_selector("dialog.modal[open]", visible: true)
    end

    it "navigates to next image when next button is clicked" do
      visit gallery_path
      first("[data-gallery-target='item']").click
      within("dialog.modal[open]") do
        find("button[aria-label='Sonraki']").click
      end
      expect(page).to have_selector("dialog.modal[open]", visible: true)
    end

    it "closes lightbox when close button is clicked" do
      visit gallery_path
      first("[data-gallery-target='item']").click
      within("dialog.modal[open]") do
        find("button[aria-label='Kapat']").click
      end
      expect(page).not_to have_selector("dialog.modal[open]", visible: true)
    end
  end
end
