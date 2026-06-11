class Discipline < ApplicationRecord
  include Normalizable

  # Associations
  has_many :trainer_disciplines, dependent: :destroy
  has_many :trainers, through: :trainer_disciplines

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Normalizations
  normalizes_stripped :name
end
