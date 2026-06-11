# Reusable normalizers for use with ActiveModel's `normalizes`.
#
# Example:
#   include Normalizable
#   normalizes_titlecase :name, :title
#   normalizes_stripped :slug
#   normalizes_downcased :email_address

module Normalizable
  extend ActiveSupport::Concern

  # Unicode-safe title casing. Unlike String#titleize, this preserves non-ASCII uppercase letters (e.g. Turkish Ç, Ö, Ü, Ş, Ğ, İ) at word starts instead of dropping them to lowercase.
  TITLECASE = ->(value) { value.to_s.split.map(&:capitalize).join(" ") }

  # Trims surrounding whitespace.
  STRIP = ->(value) { value.to_s.strip }

  # Trims surrounding whitespace and lowercases.
  DOWNCASE = ->(value) { value.to_s.strip.downcase }

  class_methods do
    def normalizes_titlecase(*attributes)
      normalizes(*attributes, with: TITLECASE)
    end

    def normalizes_stripped(*attributes)
      normalizes(*attributes, with: STRIP)
    end

    def normalizes_downcased(*attributes)
      normalizes(*attributes, with: DOWNCASE)
    end
  end
end
