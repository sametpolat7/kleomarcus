class MembershipPlan < ApplicationRecord
  include Normalizable

  # Constants
  PRICE_DELIMITER = ".".freeze

  # Validations
  validates :name, :description, presence: true
  validates :monthly_price, numericality: { only_integer: true, greater_than: 0, less_than: 1_000_000 }
  validates :position, numericality: { only_integer: true, greater_than: 0 }

  # Normalizations
  normalizes_stripped :name, :description

  # Scopes
  scope :ordered, -> { order(:position) }

  # Accepts the thousands separator the admin form displays, so "8.000" is stored as 8000.
  def monthly_price=(value)
    super(value.is_a?(String) ? value.strip.delete(PRICE_DELIMITER) : value)
  end

  def formatted_monthly_price
    ActiveSupport::NumberHelper.number_to_delimited(monthly_price, delimiter: PRICE_DELIMITER)
  end
end
