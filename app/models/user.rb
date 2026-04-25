class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy

  enum role: { user: 0, admin: 1 }

  validates :email_address, presence: true, uniqueness: true
end
