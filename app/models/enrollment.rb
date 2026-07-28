class Enrollment < ApplicationRecord
  include Normalizable

  # Constants
  PHONE_REGEXP = /\A(?:\+90|0)?5\d{9}\z/

  # Attributes
  attribute :info_consent, :boolean
  attribute :kvkk_consent, :boolean

  # Enums
  enum :status, { received: 0, called: 1, positive: 2, negative: 3, undecided: 4 }, validate: true

  # Validations
  validates :full_name, presence: true, length: { maximum: 100 }
  validates :phone, presence: true, format: { with: PHONE_REGEXP, allow_blank: true }
  validates :email, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :age, presence: true, numericality: {
    only_integer: true, greater_than_or_equal_to: 3, less_than_or_equal_to: 75, allow_nil: true
  }
  validates :message, length: { maximum: 1000 }
  validates :info_consent, acceptance: { allow_nil: false }, on: :create
  validates :kvkk_consent, acceptance: { allow_nil: false }, on: :create

  # Normalizations
  normalizes_titlecase :full_name
  normalizes_downcased :email
  normalizes :phone, with: ->(value) {
    digits = value.to_s.gsub(/[\s\-().+]/, "")
    digits = digits.delete_prefix("90") if digits.length == 12 && digits.start_with?("90")

    digits.length == 10 && digits.start_with?("5") ? "0#{digits}" : digits
  }

  # Callbacks
  before_save :stamp_kvkk_acceptance

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  private

  def stamp_kvkk_acceptance
    self.kvkk_accepted_at ||= Time.current if kvkk_consent
  end
end
