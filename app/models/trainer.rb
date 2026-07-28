class Trainer < ApplicationRecord
  include Normalizable

  # Constants
  PHOTO_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  PHOTO_MAX_SIZE = 5.megabytes

  # Associations
  has_one_attached :photo
  has_many :lessons, dependent: :nullify
  has_many :trainer_disciplines, dependent: :destroy
  has_many :disciplines, through: :trainer_disciplines

  # Validations
  validates :name, :title, presence: true
  validates :position, numericality: { only_integer: true, greater_than: 0 }
  validate :photo_is_a_supported_image

  # Normalizations
  normalizes_stripped :name, :title

  # Callbacks
  before_validation :assign_default_position, on: :create
  before_save :make_room_at_position, if: :will_save_change_to_position?

  # Scopes
  scope :ordered, -> { order(:position) }

  private

  def assign_default_position
    self.position ||= (self.class.maximum(:position) || 0) + 1
  end

  def photo_is_a_supported_image
    return unless photo.attached?

    unless PHOTO_CONTENT_TYPES.include?(photo.blob.content_type)
      errors.add(:photo, "JPEG, PNG veya WebP olmalıdır")
    end

    if photo.blob.byte_size > PHOTO_MAX_SIZE
      errors.add(:photo, "en fazla #{PHOTO_MAX_SIZE / 1.megabyte} MB olabilir")
    end
  end

  def make_room_at_position
    previous = attribute_was(:position)
    siblings = self.class.where.not(id: id)

    if previous.nil?
      siblings.where(position: position..).update_all("position = position + 1")
    elsif position < previous
      siblings.where(position: position...previous).update_all("position = position + 1")
    else
      siblings.where(position: (previous + 1)..position).update_all("position = position - 1")
    end
  end
end
