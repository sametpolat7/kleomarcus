class Discipline < ApplicationRecord
  # Associations
  has_many :trainer_disciplines, dependent: :destroy
  has_many :trainers, through: :trainer_disciplines

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Normalizations
  normalizes :name, with: ->(value) { value.strip }
end
