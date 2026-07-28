require "rails_helper"

RSpec.describe "Visitor lands on the homepage", :js, type: :system do
  it "switches the theme and remembers the choice" do
    visit root_path
    page.execute_script("localStorage.setItem('theme', 'pastel')")
    visit root_path
    wait_for_stimulus("theme")

    find("label.swap").click

    expect(page).to have_css("html[data-theme='dracula']")
    expect(page.evaluate_script("localStorage.getItem('theme')")).to eq("dracula")

    visit root_path
    expect(page).to have_css("html[data-theme='dracula']")
  end

  it "opens the mobile menu" do
    visit root_path

    find('button[aria-label="Menüyü aç"]').click

    expect(page).to have_css("#mobile-menu", visible: true)
  end
end
