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
              card_receipt_method: 'mail',
              phone_number: '5555555555',
              email: 'new@email.com'
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
      expect(aid_application.phone_number).to eq '5555555555'
      expect(aid_application.email).to eq 'new@email.com'
    end

    context 'when Update and re-send button clicked' do
      before do
        put :update, params: {
            aid_application_id: aid_application.id,
            organization_id: assister.organization.id,
            aid_application: {
                phone_number: '1234567890',
                email: 'updated@email.com'
            },
            form_action: 'update_and_resend'
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
        expect(aid_application.phone_number).to eq '1234567890'
        expect(aid_application.email).to eq 'updated@email.com'
      end

      it 'remains on the Review and submit page' do
        expect(response).to redirect_to edit_organization_aid_application_confirmation_path(assister.organization, aid_application)
      end
    end

    context 'when submit button is clicked' do
      it 'redirects to the dashboard page' do
        expect(response).to redirect_to organization_dashboard_path(assister.organization)
      end
    end
  end
end
