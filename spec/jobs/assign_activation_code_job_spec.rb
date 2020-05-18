require 'rails_helper'

RSpec.describe AssignActivationCodeJob, type: :job do
  let!(:aid_application) { create :aid_application }
  let!(:payment_card) { create :payment_card, aid_application: aid_application, activation_code: '123456' }

  before do
    allow(BlackhawkApi).to receive(:activate).and_return(true)
  end

  it 'marks the activation code as assigned' do
    described_class.perform_now(payment_card: payment_card)

    payment_card.reload
    expect(payment_card.blackhawk_activation_code_assigned_at).to be_within(1.second).of Time.current
  end

  context 'when there is not an activation code' do
    before do
      payment_card.update(activation_code: nil)
    end

    it 'raises an exception' do
      expect do
        described_class.perform_now(payment_card: payment_card)
      end.to raise_error AssignActivationCodeJob::MissingActivationCode
    end
  end

  context 'when there is not an aid application' do
    before do
      payment_card.update(aid_application: nil)
    end

    it 'raises an exception' do
      expect do
        described_class.perform_now(payment_card: payment_card)
      end.to raise_error AssignActivationCodeJob::MissingAidApplication
    end
  end

  context 'when it has already been assigned' do
    before do
      payment_card.update(blackhawk_activation_code_assigned_at: 5.minutes.ago)
    end

    it 'raises an exception' do
      expect do
        described_class.perform_now(payment_card: payment_card)
      end.to raise_error AssignActivationCodeJob::PaymentCardAlreadyAssigned
    end
  end
end
