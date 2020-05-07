class ApplicationTexter < ActionMailer::Base
  default from: -> { deliver_with_twilio? ? nil : 'SMS' },
          subject: '',
          delivery_method: -> { deliver_with_twilio? ? :twilio_sms : nil },
          delivery_method_options: {
            messaging_service_sid: Rails.application.secrets.twilio_messaging_service_sid,
          }

  def basic_message(to:, body:)
    phone_number = PhoneNumberFormatter.format(to)

    mail(to: phone_number, body: body) do |format|
      format.text { render plain: body }
    end
  end

  private

  def deliver_with_twilio?
    !Rails.application.config.action_mailer.delivery_method.in?([:letter_opener, :test])
  end
end
