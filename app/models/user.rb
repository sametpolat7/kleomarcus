class User < ApplicationRecord
  include Normalizable

  # Attributes
  has_secure_password

  # Enums
  enum :role, { admin: 0, staff: 1 }

  # Associations
  has_many :sessions, dependent: :destroy

  # Validations
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[a-z0-9_]+\z/ }
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }

  # Normalizations
  normalizes_downcased :username, :email_address

  def panel_access?
    admin? || staff?
  end
end
