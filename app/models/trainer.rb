class Trainer < ApplicationRecord
  include Normalizable

  # Associations
  has_one_attached :photo
  has_many :lessons, dependent: :nullify
  has_many :trainer_disciplines, dependent: :destroy
  has_many :disciplines, through: :trainer_disciplines

  # Validations
  validates :name, :title, presence: true

  # Normalizations
  normalizes_titlecase :name, :title

  # Callbacks
  before_validation :assign_default_position, on: :create
  before_create :shift_positions_down, if: :position?

  # Scopes
  scope :ordered, -> { order(:position) }

  private

  def assign_default_position
    self.position ||= (self.class.maximum(:position) || 0) + 1
  end

  def shift_positions_down
    self.class.where("position >= ?", position).update_all("position = position + 1")
  end
end
