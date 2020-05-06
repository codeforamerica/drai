require 'rails_helper'

describe ApplicationTexter do
  let(:application_delivery_method) { :smtp }
  let(:twilio_client) { instance_double(Twilio::REST::Client, messages: twilio_messages) }
  let(:twilio_response) { OpenStruct.new(sid: "12345") }
  let(:twilio_messages) { instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList, create: twilio_response) }

  around do |example|
    original_delivery_method = Rails.application.config.action_mailer.delivery_method
    Rails.application.config.action_mailer.delivery_method = application_delivery_method
    example.call
    Rails.application.config.action_mailer.delivery_method = original_delivery_method
  end

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
  end

  context 'when the default Rails delivery method is SMTP' do
    it 'uses the Twilio SMS delivery method' do
      ApplicationTexter.basic_message(to: "123-456-7890", body: "hello").deliver_now

      expect(twilio_messages).to have_received(:create).with(
        messaging_service_sid: Rails.application.secrets.twilio_messaging_service_sid,
        to: '+11234567890',
        body: 'hello'
      )
    end
  end

  context 'when the default Rails delivery method is test' do
    let(:application_delivery_method) { :test }

    it 'uses test delivery method' do
      ApplicationTexter.basic_message(to: "123-456-7890", body: "hello").deliver_now

      expect(twilio_messages).not_to have_received(:create)
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end
  end

  context 'when the default Rails delivery method is letter_opener' do
    let(:application_delivery_method) { :letter_opener }

    it 'does not send through Twilio' do
      ApplicationTexter.basic_message(to: "123-456-7890", body: "hello").deliver_now

      expect(twilio_messages).not_to have_received(:create)
    end
  end
end
