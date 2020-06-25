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

  describe '#undisburse_payment_card' do
    let!(:disbursed_aid_application) { create :aid_application, :disbursed }

    it 'undisburses the payment card' do
      payment_card = disbursed_aid_application.payment_card

      put :undisburse_payment_card, params: {
        undisburse_payment_card: {
          sequence_number: payment_card.sequence_number,
        }
      }

      expect(disbursed_aid_application.reload).to have_attributes(
                                                    status: :approved,
                                                    disbursed_at: nil,
                                                    disburser: nil,
                                                    payment_card: nil,
                                                  )

      expect(payment_card.reload).to have_attributes(
                                       aid_application: nil,
                                       activation_code: nil,
                                       blackhawk_activation_code_assigned_at: nil,
                                     )
    end
  end


  describe '#import_payment_cards' do
    it 'imports cards' do
      post :import_payment_cards, params: {
        import_payment_cards: {
          quote_number: '555555',
          csv_text: <<~CSV
            SEQUENCE #,Proxy,CLEANSED PAN,CLIENT ORDER NUMBER
            123456,111122223333,9999-XXXX-XXXX-1111,123123
          CSV
        }
      }

      expect(PaymentCard.last).to have_attributes(
                                    quote_number: '555555',
                                    sequence_number: '123456',
                                    proxy_number: '111122223333',
                                    card_number: '9999-XXXX-XXXX-1111',
                                    client_order_number: '123123',
                                  )
    end
  end
end
