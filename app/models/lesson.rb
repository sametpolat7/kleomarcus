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
  validate :end_time_after_start_time

  # Scopes
  scope :ordered, -> { order(:day_of_week, :start_time) }

  class << self
    def schedule_days
      day_of_weeks.keys.rotate(1)
    end

    def schedule_hours
      distinct.order(:start_time).pluck(:start_time, :end_time).map do |start_time, end_time|
        [ start_time.strftime("%H:%M"), end_time.strftime("%H:%M") ]
      end
    end

    # day_of_week enum mirrors Date#wday (Sunday=0..Saturday=6), which is the index I18n's date.day_names uses.
    def day_name(day)
      wday_index = day_of_weeks.fetch(day.to_s)
      I18n.t("date.day_names").fetch(wday_index)
    end
  end

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    return if end_time > start_time

    errors.add(:end_time, "başlangıç saatinden sonra olmalıdır")
  end
end
