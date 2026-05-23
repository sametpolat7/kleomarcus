class User < ApplicationRecord
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
            format: { with: /\A[a-z0-9_]+\z/, message: "yalnızca küçük harf, rakam ve alt çizgi içerebilir" }
  validates :email_address, presence: true, uniqueness: true

  # Normalizations
  normalizes :username, with: ->(value) { value.strip.downcase }

  def panel_access?
    admin? || staff?
  end
end
