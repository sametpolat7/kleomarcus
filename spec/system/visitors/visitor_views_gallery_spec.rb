require "rails_helper"

RSpec.describe "Visitor browses the gallery", :js, type: :system do
  include Public::GalleriesHelper

  before do
    visit gallery_path
    wait_for_stimulus("gallery")
  end

  def photo_sources
    all("[data-gallery-target='item'] img", visible: :all).map { |img| img[:src] }
  end

  it "opens the clicked photo in the lightbox" do
    first_photo = photo_sources.first

    first("[data-gallery-target='item']").click

    within("dialog.modal[open]") do
      expect(find("img")[:src]).to eq(first_photo)
      expect(find("span")).to have_text("1 / #{gallery_images.size}")
    end
  end

  it "moves on to the next photo" do
    second_photo = photo_sources.second

    first("[data-gallery-target='item']").click
    within("dialog.modal[open]") { find("button[aria-label='Sonraki']").click }

    within("dialog.modal[open]") do
      expect(find("img")[:src]).to eq(second_photo)
      expect(find("span")).to have_text("2 / #{gallery_images.size}")
    end
  end

  it "closes the lightbox from the close button" do
    first("[data-gallery-target='item']").click
    within("dialog.modal[open]") { find("button[aria-label='Kapat']").click }

    expect(page).not_to have_selector("dialog.modal[open]")
  end

  it "closes the lightbox when the backdrop is clicked" do
    first("[data-gallery-target='item']").click
    find("dialog.modal[open] .modal-backdrop").click(x: 5, y: 5, offset: :position)

    expect(page).not_to have_selector("dialog.modal[open]")
  end
end
