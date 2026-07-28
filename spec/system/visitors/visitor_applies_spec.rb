require "rails_helper"

RSpec.describe "Visitor fills in the application form", :js, type: :system do
  before do
    visit new_enrollment_path
    wait_for_stimulus("numeric-input")
  end

  it "keeps nothing but digits in the phone field" do
    fill_in "enrollment_phone", with: "0532 123-45.67"

    expect(find("#enrollment_phone").value).to eq("05321234567")
  end

  it "rewrites a pasted +90 number into the local form" do
    fill_in "enrollment_phone", with: "+90 532 123 45 67"

    expect(find("#enrollment_phone").value).to eq("05321234567")
  end

  it "holds the age down to two digits" do
    fill_in "enrollment_age", with: "12a34"

    expect(find("#enrollment_age").value).to eq("12")
  end
end
