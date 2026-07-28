class User < ApplicationRecord
  include Normalizable

  # Constants
  MINIMUM_PASSWORD_LENGTH = 8
  ASSIGNABLE_ROLES = %w[admin staff].freeze

  # Attributes
  has_secure_password

  # Enums
  enum :role, { admin: 0, staff: 1, athlete: 2 }, validate: true

  # Associations
  has_many :sessions, dependent: :destroy

  # Validations
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[a-z0-9_]+\z/ }
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: MINIMUM_PASSWORD_LENGTH }, allow_nil: true

  # Normalizations
  normalizes_downcased :username, :email_address

  def panel_access?
    admin? || staff?
  end
end
