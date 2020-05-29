module Webhooks
  class TwilioController < BaseController
    before_action :verify_webhook

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

    private

    def verify_webhook
      twilio_signature = request.headers['X-Twilio-Signature']
      auth_token = Rails.application.secrets.twilio_auth_token
      validator = Twilio::Security::RequestValidator.new(auth_token)

      return if validator.validate(request.url, request.POST, twilio_signature)

      render plain: "unauthorized", status: 401
    end
  end
end
