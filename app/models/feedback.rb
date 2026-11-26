class Feedback < ApplicationRecord
  # Constants
  MESSAGE_LENGTH = (10..1000)

  # Enums
  enum :topic, { trainers: 0, facility: 1, classes: 2, other: 3 }, validate: true

  # Validations
  validates :message, presence: true, length: { in: MESSAGE_LENGTH, allow_blank: true }

  # Normalizations
  normalizes :message, with: ->(value) { value.to_s.gsub("\r\n", "\n").strip }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
end
