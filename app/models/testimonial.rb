class Testimonial < ApplicationRecord
  include Normalizable

  # Validations
  validates :author_name, :content, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }

  # Normalizations
  normalizes_titlecase :author_name, :title

  # Scopes
  scope :ordered, -> { order(created_at: :desc) }

  def initials
    parts = author_name.to_s.scan(/\p{L}+/u).first(2)
    return "?" if parts.empty?

    parts.map { |p| "#{p[0].upcase}." }.join
  end
end
