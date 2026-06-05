class Testimonial < ApplicationRecord
  # Validations
  validates :author_name, :content, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }

  # Normalizations
  normalizes :author_name, :title, with: ->(value) { value&.titleize }

  # Scopes
  scope :ordered, -> { order(created_at: :desc) }

  # TODO: Can be removed?
  def initials
    parts = author_name.to_s.scan(/\p{L}+/u).first(2)
    return "?" if parts.empty?

    parts.map { |p| "#{p[0].upcase}." }.join
  end
end
