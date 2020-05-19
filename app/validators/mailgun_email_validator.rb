class MailgunEmailValidator < ActiveModel::EachValidator
  ERROR_MESSAGE_KEY = 'activerecord.errors.messages.email_invalid'
  SECONDS_TO_WAIT = 60

  UnsuccessfulRequestException = Class.new(StandardError)

  def validate_each(record, attribute, value)
    return if record.errors[attribute].present?
    return if self.class.valid?(value)

    record.errors[attribute] << I18n.t(ERROR_MESSAGE_KEY)
  end

  # from Mailgun API docs for email validation
  # https://documentation.mailgun.com/en/latest/api-email-validation.html#example
  def self.valid?(email_address)
    public_key = Rails.application.secrets.mailgun_validation_api_key
    validate_url = "https://api.mailgun.net/v4/address/validate"

    return true if public_key.blank?

    begin
      response = HTTParty.get(validate_url,
                   timeout: SECONDS_TO_WAIT,
                   query: { "address" => email_address },
                   basic_auth: {
                     username: 'api',
                     password: public_key,
                   })

      unless response.success?
        raise UnsuccessfulRequestException.new("#{response.code} - #{response.message}")
      end

      response["result"] == 'deliverable'
    rescue Net::ReadTimeout, Net::OpenTimeout
      Rails.logger.info('Mailgun timed out on this request')
      true
    rescue UnsuccessfulRequestException => e
      Raven.capture_exception(e)
      true
    end
  end
end
