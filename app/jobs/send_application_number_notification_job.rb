class SendApplicationNumberNotificationJob < ApplicationJob
  queue_as :default

  def perform(aid_application:)
    if aid_application.sms_consent?
      ApplicationTexter.basic_message(
          to: aid_application.phone_number,
          body: I18n.t('text_message.app_id', app_id: aid_application.application_number)
        ).deliver_now
    elsif aid_application.email_consent?
      ApplicationEmailer.basic_message(
          to: aid_application.email,
          subject: I18n.t('email_message.app_id.subject', app_id: aid_application.application_number),
          body: I18n.t('email_message.app_id.body_html', app_id: aid_application.application_number)
        ).deliver_now
    end
  end
end
