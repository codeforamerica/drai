require 'rails_helper'

describe Webhooks::MailgunController do
  let(:mailgun_api_key) { "abcdef" }

  before do
    allow(Rails.application.secrets).to receive(:mailgun_api_key).and_return(mailgun_api_key)
  end

  describe '#status' do
    let(:message_id) { 'something@localhost' }
    let(:params) do
      {
        "signature" => {
          "timestamp" => "12345",
          "token" => "token",
          "signature" => OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, mailgun_api_key, "12345token"),
        },
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

      expect(response).to have_http_status :ok

      message_log = MessageLog.last
      expect(message_log).to have_attributes(
                               message_id: message_id,
                               status: 'opened'
                             )
    end
  end

  describe '#inbound' do
    let(:params) do
      {
        from: "Bob <bob@example.com>",
        subject: "Help!",
        body: "help",
        timestamp: "12345",
        token: "token",
        signature: OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, mailgun_api_key, "12345token"),
      }
    end

    it 'replies with a message' do
      expect do
        post :inbound, params: params
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
        "ApplicationEmailer", "basic_message", "deliver_now",
        args: [{
                 to: "Bob <bob@example.com>",
                 subject: I18n.t('email_message.auto_response.subject', locale: 'en'),
                 body: I18n.t('email_message.auto_response.body_html', locale: 'en')
               }]
      )
    end
  end
end
