class FiveDigitZipValidator < ActiveModel::EachValidator
  ZIP_CODE_REGEX = /\A\d{5}\z/

  def validate_each(record, attr_name, value)
    unless value.blank? || (value =~ ZIP_CODE_REGEX)
      record.errors[attr_name] << I18n.t('activerecord.errors.messages.zip_five_digits')
    end
  end
end

