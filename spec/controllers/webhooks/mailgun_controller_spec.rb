require 'rails_helper'

describe Webhooks::MailgunController do
  describe '#status' do
    let(:message_id) { 'something@localhost' }
    let(:params) do
      {
        "event-data" => {
          "id" => rand(100000...9999999),
          "event" => 'opened',
          "message" => {
            "headers" => {
              "message-id" => message_id,
            },
          },
        },
      }
    end

    it 'creates a new message' do
      post :status, params: params

      message_log = MessageLog.last
      expect(message_log).to have_attributes(
                                message_id: message_id,
                                status: 'opened'
                              )
    end
  end
end
