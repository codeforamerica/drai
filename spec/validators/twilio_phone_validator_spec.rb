require 'rails_helper'

describe TwilioPhoneValidator do
  subject { described_class.new(attributes: [:phone_number]) }

  let!(:aid_application) { OpenStruct.new(errors: { phone_number: [] }) }

  it 'considers many numbers to be valid' do
    subject.validate_each(aid_application, :phone_number, '1112223333')
    expect(aid_application.errors[:phone_number]).not_to be_present
  end

  context 'when twilio says a phone number is very invalid' do
    before do
      allow_any_instance_of(FakeTwilioPhoneNumberContext).to receive(:fetch).and_raise(FakeTwilioRestError, code: 20404)
    end

    it 'returns a validation error' do
      subject.validate_each(aid_application, :phone_number, '1112223333')
      expect(aid_application.errors[:phone_number]).to be_present
    end

    context 'but the fake number is on the allowed list' do
      it 'does not return a validation error' do
        subject.validate_each(aid_application, :phone_number, '1234567890')
        expect(aid_application.errors[:phone_number]).not_to be_present
      end
    end
  end

  context 'when twilio gets information from a carrier that a phone number is invalid' do
    let(:phone_number) { '1112223333' }

    before do
      fake_fetch_result = double(FakeTwilioPhoneNumberInstance, # rubocop:disable RSpec/VerifiedDoubles
                                 phone_number: phone_number,
                                 carrier: { 'error_code' => 60600 })
      allow_any_instance_of(FakeTwilioPhoneNumberContext).to receive(:fetch).and_return(fake_fetch_result)
    end

    it 'returns a validation error' do
      subject.validate_each(aid_application, :phone_number, phone_number)
      expect(aid_application.errors[:phone_number]).to be_present
    end
  end

  context 'when twilio returns no carrier information even though we asked for it' do
    let(:phone_number) { '1112223333' }

    before do
      allow(Rails.logger).to receive(:info).and_call_original
      fake_fetch_result = instance_double(FakeTwilioPhoneNumberInstance, phone_number: phone_number, carrier: nil)
      allow_any_instance_of(FakeTwilioPhoneNumberContext).to receive(:fetch).and_return(fake_fetch_result)
    end

    it 'returns true (just in case) and logs the phone number' do
      subject.validate_each(aid_application, :phone_number, phone_number)
      expect(aid_application.errors[:phone_number]).not_to be_present
      expect(Rails.logger).to have_received(:info).with(/#{phone_number}/)
    end
  end

  it 'falls back to another validation strategy if twilio does not respond quickly' do
    allow_any_instance_of(FakeTwilioPhoneNumberContext).to receive(:fetch).and_raise(Faraday::TimeoutError)

    subject.validate_each(aid_application, :phone_number, '1112223333')
    expect(aid_application.errors[:phone_number]).not_to be_present
  end

  context 'with a non-cleaned phone number' do
    let(:phone_number) { '(510) 555-1234' }

    before do
      allow(Rails.logger).to receive(:info).and_call_original
    end

    it 'submits the cleaned phone number to twilio' do
      expect_any_instance_of(FakeTwilioLookups).to receive(:phone_numbers).with('5105551234')
      subject.validate_each(aid_application, :phone_number, phone_number)
    end
  end

  describe 'when an unexpected exception occurs' do
    let(:exception) { StandardError.new("A problem happened") }

    before do
      allow_any_instance_of(FakeTwilioPhoneNumberContext).to receive(:fetch).and_raise(exception)
      allow(Raven).to receive(:capture_exception)
    end

    it 'returns true and tells sentry' do
      subject.validate_each(aid_application, :phone_number, '1112223333')
      expect(aid_application.errors[:phone_number]).not_to be_present
      expect(Raven).to have_received(:capture_exception).with(exception)
    end
  end
end
