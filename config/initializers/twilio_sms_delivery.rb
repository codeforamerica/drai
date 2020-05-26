require Rails.application.root.join('app', 'lib', 'phone_number_formatter')

module Mail
  class TwilioSmsDelivery
    attr_reader :response

    def initialize(options)
      @options = options
    end

    def deliver!(mail)
      twilio_client = Twilio::REST::Client.new

      @response = twilio_client.messages.create(
        @options.merge(
          to: PhoneNumberFormatter.format(Array(mail.to).first),
          body: mail.body.raw_source,
          status_callback: UrlHelpers.status_webhooks_twilio_url
        )
      )
      mail.message_id = @response.sid
    end
  end
end

ActionMailer::Base.add_delivery_method :twilio_sms, Mail::TwilioSmsDelivery
