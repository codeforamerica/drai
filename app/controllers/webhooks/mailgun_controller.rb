module Webhooks
  class MailgunController < BaseController
    def status
      message_id = params.dig('event-data', 'message', 'headers', 'message-id')
      return if message_id.blank?

      status = params.dig('event-data', 'event')
      status_message = params.dig('event-data', 'severity')

      message_log = MessageLog.find_or_create_by message_id: message_id
      message_log.assign_status(
        status: status,
        status_code: status_message
      )
      message_log.save

      render json: { ok: true }
    end
  end
end
