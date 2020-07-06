require 'rails_helper'

describe AidApplications::DisbursementsController do
  let!(:aid_application) { create :aid_application, :approved }

  before do
    sign_in aid_application.approver
  end

  render_views

  it 'renders' do
    get :edit, params: {
      organization_id: aid_application.organization.id,
      aid_application_id: aid_application.id
    }

    expect(response).to have_http_status :ok
  end

  context 'when the card has been disbursed' do
    let!(:aid_application) { create :aid_application, :disbursed }

    it 'redirects to the activation instructions path' do
      get :edit, params: {
        organization_id: aid_application.organization.id,
        aid_application_id: aid_application.id
      }

      expect(response).to redirect_to edit_organization_aid_application_finished_path(aid_application.organization, aid_application)
    end
  end

  describe '#update' do
    let(:payment_card) { create :payment_card }

    before do
      aid_application.update card_receipt_method: nil
    end

    it 'finds and updates the payment card and card receipt method' do
      put :update, params: {
        organization_id: aid_application.organization.id,
        aid_application_id: aid_application.id,
        search_card: {
          sequence_number: payment_card.sequence_number,
          sequence_number_confirmation: payment_card.sequence_number,
          aid_application: {
            card_receipt_method: 'mail'
          }
        }
      }

      expect(payment_card.reload.aid_application).to eq aid_application
      expect(aid_application.reload.card_receipt_method).to eq 'mail'
    end
  end
end
