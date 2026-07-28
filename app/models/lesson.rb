class Lesson < ApplicationRecord
  TIME_FORMAT = "%H:%M".freeze

  # Enums
  enum :day_of_week, {
    sunday: 0,
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6
  }, validate: { allow_nil: true }
  enum :kind, { solo: 0, team: 1 }, validate: { allow_nil: true }

  # Associations
  belongs_to :trainer, optional: true

  # Validations
  validates :name, :day_of_week, :kind, :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validate :not_duplicate_in_slot

  # Scopes
  scope :ordered, -> { order(:day_of_week, :start_time) }

  class << self
    # The weekly grid itself: { day => { "HH:MM" => [lessons] } }.
    def schedule
      ordered.includes(:trainer).group_by(&:day_of_week).transform_values do |lessons|
        lessons.group_by(&:start_label)
      end
    end

    def schedule_days
      day_of_weeks.keys.rotate(1)
    end

    def schedule_hours
      order(:start_time).group(:start_time).maximum(:end_time).map do |start_time, end_time|
        [ start_time.strftime(TIME_FORMAT), end_time.strftime(TIME_FORMAT) ]
      end
    end

    def schedule_kinds
      schedule.transform_values do |lessons_by_hour|
        lessons_by_hour.transform_values { |lessons| lessons.any?(&:team?) ? "team" : "solo" }
      end
    end

    # day_of_week enum mirrors Date#wday (Sunday=0..Saturday=6), which is the index I18n's date.day_names uses.
    def day_name(day)
      wday_index = day_of_weeks.fetch(day.to_s)
      I18n.t("date.day_names").fetch(wday_index)
    end
  end

  def start_label
    start_time.strftime(TIME_FORMAT)
  end

  def end_label
    end_time.strftime(TIME_FORMAT)
  end

  def time_range
    "#{start_label}–#{end_label}"
  end

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    return if end_time > start_time

    errors.add(:end_time, "başlangıç saatinden sonra olmalıdır")
  end

  def not_duplicate_in_slot
    return if name.blank? || day_of_week.blank? || start_time.blank?

    scope = self.class.where(name: name, day_of_week: day_of_week, start_time: start_time)
    scope = scope.where.not(id: id) if persisted?
    return unless scope.exists?

    errors.add(:base, "Aynı isimle, aynı gün ve saatte ders eklenemez.")
  end
end
