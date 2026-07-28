class Session < ApplicationRecord
  # Constants
  LIFETIME = 1.week

  # Associations
  belongs_to :user

  # Callbacks
  before_validation :set_expiration, on: :create

  # Scopes
  scope :expired, -> { where(expires_at: ..Time.current).or(where(expires_at: nil)) }

  def expired?
    expires_at.nil? || expires_at.past?
  end

  private

  def set_expiration
    self.expires_at ||= LIFETIME.from_now
  end
end
