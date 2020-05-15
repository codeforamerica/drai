class TwilioPhoneValidator < ActiveModel::EachValidator
  SECONDS_TO_WAIT = 3

  ALLOWED_NUMBERS = ['1234567890', '5551112222']

  def validate_each(record, attribute, value)
    return if ALLOWED_NUMBERS.include?(value)

    if record.errors[attribute].blank?
      unless valid?(value, record)
        record.errors[attribute] << "Make sure your phone number is valid"
      end
    end
  end

  private

  def valid?(phone_number, _record)
    http_client = Twilio::HTTP::Client.new(timeout: SECONDS_TO_WAIT)
    client = Twilio::REST::Client.new(nil, nil, nil, nil, http_client)
    cleaned_number = phone_number.gsub(/\D+/, '')
    begin
      response = client.lookups.phone_numbers(cleaned_number)
      lookup_info = response.fetch(type: 'carrier') # if invalid, 'fetch' throws an exception. If valid, no problems.
      carrier_info = lookup_info.carrier
      unless carrier_info
        Rails.logger.info("No carrier info found for #{phone_number}")
        return true
      end

      if carrier_info['error_code'].present?
        return false
      end

      return true

    rescue Twilio::REST::RestError => e
      return e.code != 20404
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Net::OpenTimeout, Twilio::REST::TwilioError
      return true
    rescue => e
      Raven.capture_exception(e)
      return true
    end
  end
end
