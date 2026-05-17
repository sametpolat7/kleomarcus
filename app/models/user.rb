class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy

  enum :role, { athlete: 0, trainer: 1, admin: 2 }

  validates :email_address, presence: true, uniqueness: true
end
