class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.enum_label(attribute, value)
    I18n.t(value, scope: [ :activerecord, :attributes, model_name.i18n_key, attribute ], default: value.to_s.titleize)
  end
end
