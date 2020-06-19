class TwilioPhoneNumberValidator < ActiveModel::EachValidator
  SECONDS_TO_WAIT = 3

  ALLOWED_NUMBERS = ['1234567890', '5551112222']

  def validate_each(record, attribute, value)
    return if ALLOWED_NUMBERS.include?(value)
    return if record.errors[attribute].present?

    unless self.class.valid?(value, record)
      record.errors.add(attribute, :twilio_phone_number_invalid, options)
    end
  end

  def self.valid?(phone_number, record = nil)
    http_client = Twilio::HTTP::Client.new(timeout: SECONDS_TO_WAIT)
    client = Twilio::REST::Client.new(nil, nil, nil, nil, http_client)

    begin
      cleaned_number = phone_number.gsub(/\D+/, '')
      response = client.lookups.phone_numbers(cleaned_number)

      # if invalid, 'fetch' throws an exception. If valid, no problems.
      lookup_info = response.fetch(type: 'carrier')
      carrier_info = lookup_info.carrier

      return true unless carrier_info
      return false if carrier_info['error_code'].present?

      if record.present?
        record.phone_number_carrier = carrier_info['name'] if record.has_attribute?(:phone_number_carrier)
        record.phone_number_type = carrier_info['type'] if record.has_attribute?(:phone_number_type)
      end

      true
    rescue Twilio::REST::RestError => e
      e.code != 20404
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Net::OpenTimeout, Twilio::REST::TwilioError
      true
    rescue StandardError => e
      Raven.capture_exception(e)
      true
    end
  end
end
