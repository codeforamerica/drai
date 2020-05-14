require 'rails_helper'

RSpec.describe AssignActivationCodeJob, type: :job do
  let!(:aid_application) { create :aid_application }
  let!(:payment_card) { double quote_number: '123', proxy_number: '456', activation_code: '123456', activation_code_assigned_at: nil, update!: nil }

  before do
    allow(aid_application).to receive(:payment_card).and_return payment_card
    allow(BlackhawkApi).to receive(:activate).and_return(true)
    allow(payment_card).to receive(:activation_code_assigned_at=)
  end

  it 'marks the activation code as assigned' do
    Timecop.freeze do
      described_class.perform_now(aid_application: aid_application)
      expect(payment_card).to have_received(:update!).with(
        activation_code: aid_application.activation_code,
        activation_code_assigned_at: Time.current
      )
    end
  end
end
