require 'rails_helper'

describe BlackhawkApi do
  let(:access_token) { 'abc' }

  before do
    stub_request(:post, 'https://certification.marketplace.bhnapi.com/api/auth').to_return(body: { 'access_token': access_token }.to_json)
  end

  describe '#monitor' do
    before do
      stub_request(:get, 'https://certification.marketplace.bhnapi.com/cards/monitor').with(headers: { 'Authorization': "Bearer #{access_token}" }).to_return(body: { status: 'SUCCESS' }.to_json)
    end

    it 'returns "SUCCESS"' do
      api = described_class.new(client_id: 'id', client_secret: 'secret')
      result = api.monitor
      expect(result).to eq true
    end
  end

  describe '#activate' do
    before do
      stub_request(
        :post,
        "https://certification.marketplace.bhnapi.com/cards/v1/set-activation-codes"
      ).with(
        headers: { 'Authorization': "Bearer #{access_token}" },
        body: [{
                 "quoteNumber" => "95000000",
                 "proxyNumber" => "6039530407033839166",
                 "activationCode" => "123456"
               }].to_json
      ).to_return(body: { "success": true, "message": nil }.to_json)
    end

    it 'returns "SUCCESS"' do
      api = described_class.new(client_id: 'id', client_secret: 'secret')
      result = api.activate(quote_number: "95000000", proxy_number: "6039530407033839166", activation_code: "123456")
      expect(result).to eq true
    end
  end

  describe '.activate' do
    let(:api) { instance_double BlackhawkApi, authenticate: nil, activate: nil }

    before do
      allow(BlackhawkApi).to receive(:new).and_return(api)
    end

    context 'when there are not Blackhawk client_id/client_secret ENV' do
      before do
        allow(Rails.application.secrets).to receive(:blackhawk_client_id).and_return(nil)
        allow(Rails.application.secrets).to receive(:blackhawk_client_secret).and_return(nil)
      end

      it 'does not make an API request' do
        described_class.activate(quote_number: '123', proxy_number: '123', activation_code: '123')
        expect(api).not_to have_received(:activate)
      end
    end

    context 'when there is a Blackhawk client_id/client_secret ENV' do
      before do
        allow(Rails.application.secrets).to receive(:blackhawk_client_id).and_return('123')
        allow(Rails.application.secrets).to receive(:blackhawk_client_secret).and_return('abc')
      end

      it 'does not make an API request' do
        described_class.activate(quote_number: '123', proxy_number: '123', activation_code: '123')
        expect(api).to have_received(:activate)
      end
    end
  end
end
