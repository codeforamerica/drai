class ApplicationTexter < ActionMailer::Base
  default subject: '',
          delivery_method_options: {
            messaging_service_sid: Rails.application.secrets.twilio_messaging_service_sid,
          }

  def basic_message(to:, body:)
    phone_number = PhoneNumberFormatter.format(to)
    from = deliver_with_twilio?(phone_number) ? nil : 'SMS'
    delivery_method = deliver_with_twilio?(phone_number) ? :twilio_sms : nil

    mail(to: phone_number, body: body, from: from,
         delivery_method: delivery_method) do |format|
      format.text { render plain: body }
    end
  end

  private

  def deliver_with_twilio?(to)
    !Rails.application.config.action_mailer.delivery_method.in?([:letter_opener, :test]) && TwilioPhoneValidator::ALLOWED_NUMBERS.exclude?(to[2, to.length - 2])
  end
end
