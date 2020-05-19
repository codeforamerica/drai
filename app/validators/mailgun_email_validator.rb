class MailgunEmailValidator < ActiveModel::EachValidator
  VALIDATION_API_URL = "https://api.mailgun.net/v4/address/validate"
  SECONDS_TO_WAIT = 5

  # from Mailgun API docs for email validation
  # https://documentation.mailgun.com/en/latest/api-email-validation.html#example
  def self.valid?(email_address, mailgun_api_key: Rails.application.secrets.mailgun_validation_api_key)
    if mailgun_api_key.blank?
      Rails.logger.warn("Mailgun Validation API Key is blank; skipping Mailgun validation")
      return true
    end

    begin
      response = HTTP.timeout(SECONDS_TO_WAIT)
                     .basic_auth(user: 'api', pass: mailgun_api_key)
                     .get(VALIDATION_API_URL, params: { "address" => email_address })

      unless response.status.success?
        error_message = "Mailgun API Error: #{response.code} - response.body}"
        Rails.logger.warn(error_message)
        Raven.capture_message(error_message)
        return true
      end

      response_data = response.parse
      response_data["result"] == 'deliverable'
    rescue Net::ReadTimeout, Net::OpenTimeout
      Rails.logger.info('Mailgun timed out on this request')
      true
    rescue StandardError => e
      Rails.logger.error(e)
      Raven.capture_exception(e)
      true
    end
  end

  def validate_each(record, attribute, value)
    return if record.errors[attribute].any?

    unless self.class.valid?(value)
      record.errors.add(attribute, :mailgun_email_invalid, options)
    end
  end
end
