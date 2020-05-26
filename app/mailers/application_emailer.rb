class ApplicationEmailer < ActionMailer::Base
  default from: "Disaster Assistance <no-reply@#{Rails.application.secrets.email_domain}>"
  layout 'emailer'

  after_action :insert_instance_into_mail

  def self.after_delivery(mail)
    mailer = mail.mailer

    message_log = MessageLog.find_or_create_by_message_id(mail.message_id)
    message_log.update!(
      channel: 'email',
      to: mail.to.first,
      subject: mail.subject,
      body: mail.body.raw_source,
      messageable: mailer.params&.[](:messageable)
    )
  end

  def basic_message(to:, subject:, body:)
    mail(to: to, subject: subject, body: body) do |format|
      format.text { render plain: textify_html_email(body) }
      format.html { render html: body.html_safe }
    end
  end

  private

  def textify_html_email(body)
    ActionView::Base.full_sanitizer.sanitize(body)
  end

  def insert_instance_into_mail
    mail.mailer = self
  end
end
