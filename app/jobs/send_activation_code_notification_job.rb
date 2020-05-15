class SendActivationCodeNotificationJob < ApplicationJob
  def perform(aid_application:)
    if aid_application.sms_consent?
      ApplicationTexter.basic_message(
        to: aid_application.phone_number,
        body: I18n.t(
          'text_message.activation',
          activation_code: aid_application.application_code,
          ivr_phone_number: BlackhawkApi.ivr_phone_number
        )
      ).deliver_now
    elsif aid_application.email_consent?
      ApplicationEmailer.basic_message(
        to: aid_application.email,
        subject: I18n.t('email_message.activation.subject'),
        body: I18n.t(
          'email_message.activation.body_html',
          activation_code: aid_application.application_number,
          ivr_phone_number: BlackhawkApi.ivr_phone_number
        )
      ).deliver_now
    end
  end
end
