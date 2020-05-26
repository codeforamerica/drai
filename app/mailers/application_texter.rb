class ApplicationTexter < ActionMailer::Base
  default from: -> { deliver_with_twilio? ? nil : 'SMS' },
          subject: '',
          delivery_method: -> { deliver_with_twilio? ? :twilio_sms : nil },
          delivery_method_options: {
            messaging_service_sid: Rails.application.secrets.twilio_messaging_service_sid,
          }

  after_action :insert_instance_into_mail

  def self.after_delivery(mail)
    mailer = mail.mailer

    message_log = MessageLog.find_or_create_by_message_id(mail.message_id)
    message_log.update!(
      channel: 'sms',
      to: mail.to.first,
      body: mail.body.raw_source,
      messageable: mailer.params&.[](:messageable)
    )
  end

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

  def insert_instance_into_mail
    mail.mailer = self
  end
end
