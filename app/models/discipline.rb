class Discipline < ApplicationRecord
  include Normalizable
  include Transliterable

  # Associations
  has_many :trainer_disciplines, dependent: :destroy
  has_many :trainers, through: :trainer_disciplines
  has_many :enrollments, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true

  # Normalizations
  normalizes_stripped :name

  # Callbacks
  before_validation :assign_slug, if: -> { slug.blank? && name.present? }

  def self.slugify(value)
    transliterate(value).parameterize
  end

  def to_param
    slug
  end

  private

  def assign_slug
    self.slug = self.class.slugify(name)
  end
end
