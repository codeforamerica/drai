class ZipCodeValidator < ActiveModel::EachValidator
  ZIP_CODE_REGEX = /\A\d{5}\z/

  CALIFORNIA = 90001..97000

  def validate_each(record, attr_name, value)
    return if value.blank?

    unless value =~ ZIP_CODE_REGEX && value.to_i.in?(CALIFORNIA)
      record.errors[attr_name] << I18n.t('activerecord.errors.messages.zip_code')
    end
  end
end
