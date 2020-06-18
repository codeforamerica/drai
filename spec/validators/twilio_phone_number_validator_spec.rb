require 'rails_helper'

describe TwilioPhoneNumberValidator do
  class ValidatableRecord
    include ActiveModel::Validations
    attr_accessor :phone_number
  end

  subject { described_class.new(attributes: [:phone_number]) }

  let(:member) { ValidatableRecord.new }
  let(:twilio_client) { instance_double(Twilio::REST::Client) }

  let(:twilio_result) { nil }

  before do
    allow(described_class).to receive(:valid?).and_call_original

    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
    allow(twilio_client).to receive_message_chain("lookups.phone_numbers.fetch.carrier") { twilio_result }
  end

  it 'considers many numbers to be valid' do
    subject.validate_each(member, :phone_number, '123-123-1234')
    expect(member.errors[:phone_number]).not_to be_present
  end

  context 'when twilio says a phone number is very invalid' do
    let(:twilio_result) { { 'error_code' => 60600 } }

    it 'returns a validation error' do
      subject.validate_each(member, :phone_number, '1112223333')
      expect(member.errors[:phone_number]).to be_present
    end
  end
end
