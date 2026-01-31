require "rails_helper"

RSpec.describe "Homepage", type: :system do
  it "loads successfully" do
    visit root_path
    expect(page).to have_http_status(:success)
  end

  describe "theme toggle", js: true do
    it "toggles and persists theme" do
      visit root_path
      initial_theme = page.evaluate_script("document.documentElement.dataset.theme")

      find('label.swap').click

      new_theme = page.evaluate_script("document.documentElement.dataset.theme")
      expect(new_theme).not_to eq(initial_theme)
      expect(page.evaluate_script("localStorage.getItem('theme')")).to be_present
    end
  end

  describe "mobile menu", js: true do
    it "opens on click" do
      visit root_path
      find('button[aria-label="Menüyü aç"]').click
      expect(page).to have_css('#mobile-menu', visible: true)
    end
  end
end
