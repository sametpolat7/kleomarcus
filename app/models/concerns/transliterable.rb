# Transliterates characters to their ASCII equivalents — a home for
# character-level mapping logic that can be reused across models.

# Example:
#   include Transliterable
#   transliterate("Beşiktaş")   # => "Besiktas"

module Transliterable
  extend ActiveSupport::Concern

  TURKISH_TRANSLITERATIONS = {
    "ç" => "c",
    "ğ" => "g",
    "ı" => "i",
    "ö" => "o",
    "ş" => "s",
    "ü" => "u",
    "Ç" => "c",
    "Ğ" => "g",
    "İ" => "i",
    "Ö" => "o",
    "Ş" => "s",
    "Ü" => "u"
  }.freeze

  class_methods do
    def transliterate(value)
      value.to_s.chars.map { |char| TURKISH_TRANSLITERATIONS[char] || char }.join
    end
  end
end
