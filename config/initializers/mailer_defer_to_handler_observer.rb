class MailerDeferToHandlerObserver
  def self.delivered_email(mail)
    return unless mail.delivery_handler.respond_to? :after_delivery

    mail.delivery_handler.after_delivery(mail)
  end
end

class Mail::Message
  attr_accessor :mailer
end

ActionMailer::Base.register_observer(MailerDeferToHandlerObserver)
