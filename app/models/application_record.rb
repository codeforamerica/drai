class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include RescueMultiparameterErrors

  def error_message?(attr_name, key)
    (errors.details[attr_name] || []).map { |d| d[:error] }.include?(key)
  end
end
