require 'rails_helper'

describe AidApplications::ConfirmationsController do
  let(:assister) { create :assister }
  let(:aid_application) { AidApplication.create!(creator: assister, organization: assister.organization) }

  describe '#edit' do
    context 'when not authenticated' do
      it 'does not allow access' do
        get :edit, params: {
            aid_application_id: aid_application.id,
            organization_id: assister.organization.id,
        }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#update' do
    before do
      sign_in aid_application.creator

      put :update, params: {
          aid_application_id: aid_application.id,
          organization_id: assister.organization.id,
          aid_application: {
              contact_method_confirmed: true,
              card_receipt_method: 'mail'
          }
      }
    end

    it 'updates the aid application with params' do
      aid_application = assigns(:aid_application)
      expect(aid_application).to be_persisted
      expect(aid_application).to have_attributes(
                                     creator: assister,
                                     organization: assister.organization
      )
      expect(aid_application.contact_method_confirmed).to eq true
      expect(aid_application.card_receipt_method).to eq 'mail'
    end

    it 'redirects to the dashboard page' do
      expect(response).to redirect_to organization_dashboard_path(assister.organization)
    end
  end
end
