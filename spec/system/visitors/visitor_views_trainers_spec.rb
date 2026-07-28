require "rails_helper"

RSpec.describe "Visitor reads a trainer's profile", :js, type: :system do
  let!(:trainer) { create(:trainer, name: "Mehmet Demir", bio: "On yıllık ring deneyimi.") }

  before do
    visit trainers_path
    wait_for_stimulus("modal")
  end

  it "opens the trainer's card in a modal" do
    first("[data-action*='modal#open']").click

    within("dialog.modal[open]") do
      expect(page).to have_text(trainer.name)
      expect(page).to have_text("On yıllık ring deneyimi.")
    end
  end

  it "closes the modal again" do
    first("[data-action*='modal#open']").click
    within("dialog.modal[open]") { find("button.btn-circle").click }

    expect(page).not_to have_selector("dialog.modal[open]")
  end
end
