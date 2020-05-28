require 'rails_helper'

describe Webhooks::TwilioController do
  let(:twilio_validator) { instance_double(Twilio::Security::RequestValidator, validate: true) }

  before do
    allow(Twilio::Security::RequestValidator).to receive(:new).and_return(twilio_validator)
  end

  describe '#status' do
    let(:message_id) { 'ABC263609d13d809a13de985cc8fd44fb7' }
    let(:params) do
      {
        "MessageSid" => message_id,
        "MessageStatus" => "delivered",
        "To" => "+15555555555",
        "From" => "+15551234567",
        "ErrorCode" => 1,
        "ErrorMessage" => "A problem happened",
      }
    end

    it 'creates a new message_log' do
      post :status, params: params

      message_log = MessageLog.last
      expect(message_log).to have_attributes(
                           message_id: message_id,
                           status: 'delivered',
                           status_code: '1',
                           status_message: 'A problem happened'
                         )
    end
  end
end
