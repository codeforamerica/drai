module Webhooks
  class TwilioController < BaseController
    def status
      message_log = MessageLog.find_or_create_by_message_id params[:MessageSid]
      message_log.assign_status(
        status: params['MessageStatus'],
        status_code: params['ErrorCode'],
        status_message: params['ErrorMessage'],
      )
      message_log.save

      render json: { ok: true }
    end
  end
end
