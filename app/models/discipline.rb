class Discipline < ApplicationRecord
  include Normalizable

  # Associations
  has_many :trainer_disciplines, dependent: :restrict_with_error
  has_many :trainers, through: :trainer_disciplines

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Normalizations
  normalizes_stripped :name

  # Scopes
  scope :ordered, -> { order(:name) }
end
