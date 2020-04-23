module RescueMultiparameterErrors
  extend ActiveSupport::Concern

  def assign_multiparameter_attributes(pairs)
    @_invalid_multiparameter_values ||= ActiveSupport::HashWithIndifferentAccess.new
    attribute = pairs.keys.first.match(/^(.*)\(/)[1]

    begin
      super
      @_invalid_multiparameter_values.delete(attribute)
    rescue
      @_invalid_multiparameter_values[attribute] = true
    end
  end
end
