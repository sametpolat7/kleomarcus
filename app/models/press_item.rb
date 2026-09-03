class PressItem < ApplicationRecord
  include Normalizable

  # Enums
  enum :publisher_kind, {
    local_press: 0,
    national_press: 1,
    news_agency: 2,
    official_statement: 3
  }, validate: true

  # Validations
  validates :publisher, :headline, :url, :published_on, presence: true
  validates :url, uniqueness: true, format: { with: %r{\Ahttps://\S+\z}, message: "https:// ile başlayan bir adres olmalıdır" }
  validates :archive_url, format: { with: %r{\Ahttps://\S+\z}, message: "https:// ile başlayan bir adres olmalıdır" }, allow_blank: true

  # Normalizations
  normalizes_stripped :publisher, :headline, :url, :archive_url, :byline, :quote

  # Scopes
  scope :visible, -> { where(published: true) }
  scope :ordered, -> { order(published_on: :desc, id: :desc) }

  class << self
    def by_year
      ordered.group_by { |item| item.published_on.year }
    end
  end

  def unarchived?
    published? && archive_url.blank?
  end
end
