require 'rails_helper'

describe MailgunEmailValidator do
  subject { described_class.new(attributes: [:email_address]) }

  let(:member) { OpenStruct.new(errors: { email_address: [] }) }
  let(:fake_email_address) { 'a@cfa.bloop' }
  let(:response) do
    {
      "address": fake_email_address,
      "is_disposable_address": false,
      "is_role_address": false,
      "reason": [],
      "result": "deliverable",
      "risk": "low",
    }
  end

  before do
    allow(Rails.application.secrets).to receive(:mailgun_validation_api_key).and_return("blargh")

    stub_request(:get, "https://api.mailgun.net/v4/address/validate?address=#{fake_email_address}")
      .with(headers: { 'Authorization' => "Basic #{Base64.strict_encode64("api:#{Rails.application.secrets.mailgun_validation_api_key}").chomp}" })
      .to_return(status: 200, body: response.to_json, headers: { "content-type" => ["application/json"] })
  end

  context 'when Mailgun says an email address is valid' do
    it 'considers many email addresses to be valid' do
      subject.validate_each(member, :email_address, fake_email_address)
      expect(member.errors[:email_address]).not_to be_present
    end
  end

  context 'when Mailgun says an email address is invalid' do
    let(:response) do
      {
        "address": fake_email_address,
        "is_disposable_address": false,
        "is_role_address": false,
        "reason": "mailbox_does_not_exist",
        "result": "undeliverable",
        "risk": "high",
      }
    end

    it 'returns a validation error' do
      subject.validate_each(member, :email_address, fake_email_address)
      expect(member.errors[:email_address]).to be_present
    end
  end

  describe 'Mailgun is too slow' do
    before do
      stub_request(:get, "https://api.mailgun.net/v4/address/validate?address=#{fake_email_address}").to_timeout
    end

    it 'falls back on another validation strategy' do
      subject.validate_each(member, :email_address, fake_email_address)
      expect(member.errors[:email_address]).not_to be_present
    end
  end

  describe 'when a request is unsuccessful' do
    before do
      stub_request(:get, "https://api.mailgun.net/v4/address/validate?address=#{fake_email_address}")
        .to_return(status: 401, body: '')
      allow(Raven).to receive(:capture_exception)
    end

    it 'returns true and sends the error to sentry' do
      subject.validate_each(member, :email_address, fake_email_address)
      expect(member.errors[:email_address]).not_to be_present
      expect(Raven).to have_received(:capture_exception).with(MailgunEmailValidator::UnsuccessfulRequestException)
    end
  end
end
