class Swim < ApplicationRecord
  include Normalizable

  # Constants
  PHONE_REGEXP = /\A(?:\+90|0)?5\d{9}\z/

  # Attributes
  attribute :info_consent, :boolean
  attribute :kvkk_consent, :boolean

  # Enums
  enum :level, { beginner: 0, intermediate: 1, advanced: 2 }
  enum :status, { received: 0, called: 1, positive: 2, negative: 3, undecided: 4 }

  # Validations
  validates :full_name, presence: true, length: { maximum: 100 }
  validates :phone, presence: true, format: { with: PHONE_REGEXP, allow_blank: true }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :age, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 3, less_than_or_equal_to: 75, allow_nil: true }
  validates :level, presence: true
  validates :message, length: { maximum: 1000 }
  validates :info_consent, acceptance: true
  validates :kvkk_consent, acceptance: true

  # Normalizations
  normalizes_titlecase :full_name
  normalizes_downcased :email
  normalizes :phone, with: ->(value) { value.to_s.gsub(/[\s\-().]/, "") }

  # Callbacks
  before_save :stamp_kvkk_acceptance

  # Scopes
  scope :applications, -> { all }
  scope :recent, -> { order(created_at: :desc) }

  private

  def stamp_kvkk_acceptance
    self.kvkk_accepted_at ||= Time.current if kvkk_consent
  end
end
