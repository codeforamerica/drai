require 'rails_helper'

describe PaymentCard do
  it 'has a valid factory' do
    payment_card = build :payment_card
    expect(payment_card).to be_valid
  end

  describe '#replace_with' do
    let(:aid_application) { create :aid_application, :disbursed }
    let(:wrong_card) { aid_application.payment_card }
    let(:right_card) { create :payment_card }

    before do
      allow(AssignActivationCodeJob).to receive :perform_now
    end

    it 'assigns old values to new card and unassigns old card' do
      original_activation_code = wrong_card.activation_code

      wrong_card.replace_with(right_card)

      expect(right_card.aid_application).to eq aid_application
      expect(right_card.activation_code).to eq original_activation_code

      expect(wrong_card).to have_attributes(
                              aid_application: nil,
                              blackhawk_activation_code_assigned_at: nil,
                              activation_code: nil
                            )
      expect(AssignActivationCodeJob).to have_received(:perform_now).with(payment_card: right_card)
    end
  end
end
