require 'rails_helper'

describe Admin::TasksController, type: :controller do
  let(:admin) { create :admin }

  render_views

  before { sign_in admin }

  describe '#replace_payment_card' do
    let!(:disbursed_aid_application) { create :aid_application, :disbursed }
    let!(:correct_payment_card) { create :payment_card }

    before do
      allow(BlackhawkApi).to receive(:activate)
    end

    it 'replaces the payment card' do
      put :replace_payment_card, params: {
        replace_payment_card: {
          wrong_sequence_number: disbursed_aid_application.payment_card.sequence_number,
          correct_sequence_number: correct_payment_card.sequence_number
        }
      }

      expect(disbursed_aid_application.reload.payment_card.reload).to eq correct_payment_card.reload
      expect(BlackhawkApi).to have_received(:activate)
    end
  end
end
