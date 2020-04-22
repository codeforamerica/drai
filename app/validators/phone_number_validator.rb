class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.try(:match?, /\A\d{10}\z/)
      record.errors[attribute] << I18n.t('activerecord.errors.messages.phone_number')
    end
  end
end
