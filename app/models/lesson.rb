class Lesson < ApplicationRecord
  # Enums
  enum :day_of_week, {
    sunday: 0,
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6
  }
  enum :kind, { solo: 0, team: 1 }

  # Associations
  belongs_to :trainer, optional: true

  # Validations
  validates :name, :day_of_week, :start_time, :end_time, presence: true

  # Scopes
  scope :ordered, -> { order(:day_of_week, :start_time) }
end
