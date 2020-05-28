require 'openssl'

module Webhooks
  class MailgunController < BaseController
    before_action :verify_webhook

    def status
      message_id = params.dig('event-data', 'message', 'headers', 'message-id')
      return if message_id.blank?

      status = params.dig('event-data', 'event')
      status_message = params.dig('event-data', 'severity')

      message_log = MessageLog.find_or_create_by_message_id message_id
      message_log.assign_status(
        status: status,
        status_code: status_message
      )
      message_log.save

      render json: { ok: true }
    end

    def inbound
      from = params.fetch('from')
      ApplicationEmailer.basic_message(
        to: from,
        subject: I18n.t('email_message.auto_response.subject', locale: 'en'),
        body: I18n.t('email_message.auto_response.body_html', locale: 'en')
      ).deliver_later
    end

    private

    def verify_webhook
      if params['signature'].is_a?(String)
        signature = params['signature']
        timestamp = params['timestamp']
        token = params['token']
      else
        signature = params.dig('signature', 'signature')
        timestamp = params.dig('signature', 'timestamp')
        token = params.dig('signature', 'token')
      end

      digest = OpenSSL::Digest::SHA256.new
      data = [timestamp, token].join
      signing_key = Rails.application.secrets.mailgun_api_key

      return if signature == OpenSSL::HMAC.hexdigest(digest, signing_key, data)

      render plain: "unauthorized", status: 401
    end
  end
end
