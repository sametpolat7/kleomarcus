require "rails_helper"

RSpec.describe PressItem, type: :model do
  describe "url format" do
    it "rejects an address that is not https" do
      item = build(:press_item, url: "http://example.com/haber")

      expect(item).not_to be_valid
      expect(item.errors[:url]).to include("https:// ile başlayan bir adres olmalıdır")
    end

    it "rejects an address with whitespace" do
      expect(build(:press_item, url: "https://example.com/bir haber")).not_to be_valid
    end

    it "rejects a duplicate address so the same article cannot be listed twice" do
      create(:press_item, url: "https://example.com/ayni-haber")

      expect(build(:press_item, url: "https://example.com/ayni-haber")).not_to be_valid
    end

    it "applies the same rule to the archive address but allows it to be blank" do
      expect(build(:press_item, archive_url: "web.archive.org/kayit")).not_to be_valid
      expect(build(:press_item, archive_url: nil)).to be_valid
    end
  end

  describe ".visible" do
    it "returns only the records marked for publication" do
      shown = create(:press_item, :visible, headline: "Yayında olan haber")
      create(:press_item, headline: "Taslak haber")

      expect(described_class.visible).to contain_exactly(shown)
    end
  end

  describe ".ordered" do
    it "puts the most recent publication first" do
      older = create(:press_item, published_on: Date.new(2019, 4, 26))
      newer = create(:press_item, published_on: Date.new(2026, 7, 22))
      middle = create(:press_item, published_on: Date.new(2025, 2, 18))

      expect(described_class.ordered).to eq([ newer, middle, older ])
    end
  end

  describe ".by_year" do
    it "groups the records by publication year, newest year first" do
      create(:press_item, published_on: Date.new(2024, 7, 24))
      create(:press_item, published_on: Date.new(2026, 7, 22))
      create(:press_item, published_on: Date.new(2026, 1, 5))

      expect(described_class.by_year.keys).to eq([ 2026, 2024 ])
      expect(described_class.by_year[2026].size).to eq(2)
    end

    it "honours the scope it is chained onto" do
      create(:press_item, :visible, published_on: Date.new(2026, 7, 22))
      create(:press_item, published_on: Date.new(2019, 4, 26))

      expect(described_class.visible.by_year.keys).to eq([ 2026 ])
    end
  end

  describe "#unarchived?" do
    it "flags a published record that has no archive copy to fall back on" do
      expect(create(:press_item, :unarchived)).to be_unarchived
    end

    it "stays quiet once an archive copy is recorded" do
      expect(create(:press_item, :visible)).not_to be_unarchived
    end

    it "stays quiet for a draft, which is not exposed to link rot yet" do
      expect(create(:press_item, published: false, archive_url: nil)).not_to be_unarchived
    end
  end
end
